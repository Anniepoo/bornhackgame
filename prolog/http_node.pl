:- module(http_node,
          [
          bkgnd//1,
          travel//2,
          approve//1,
          simulated_travel/0,
          actual_travel/0]).
/** <module> Define a system for defining 'nodes' in a location based game
 */
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_path)).
:- use_module(library(http/js_write)).
:- use_module(library(http/html_head)).
:- use_module(library(http/http_wrapper)).
:- use_module(library(http/http_parameters)).

:- use_module(journey, [loc/3]).

bkgnd(Img) -->
    { http_absolute_location(Img, Loc, []) },
    html(img([class(background), src(Loc)], [])).

:- dynamic simulate/1.

simulated_travel :-
    asserta(simulate(travel)).

actual_travel :-
    retractall(simulate(travel)).

request_identity(Request, Identity) :-
    http_parameters(Request,
                    [user(Identity, [])]).

travel(Target , Node) -->
    {  loc(Target, Name, ll(_, _)),
       http_current_request(Request),
       request_identity(Request, Identity),
       format(atom(HREF), '/game/~w?user=~w', [Node, Identity])
    },
    html([
        \html_requires('/js/identity.js'),
         p(a(href(HREF), 'sim travel to ~w'-[Name]))
   ]).
travel(Target , Node) -->
    {  loc(Target, Name, ll(Lat, Long)) },
    html([
    \html_requires('/js/identity.js'),
    \html_requires('/js/location.js'),
         p('go to ~w at ~w ~w'-[Name, Lat, Long]),
         p(id(loc), '...loading...'),
    \js_script({|javascript(Lat, Long, Node)||
                targets.push({
                            latitude: Lat,
                            longitude: Long,
                            target: Node
                        });
               |})
   ]).

approve(Node) -->
   html(p('Approve is todo for node ~w'-[Node])).
