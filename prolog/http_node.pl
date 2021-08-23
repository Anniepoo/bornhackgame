:- module(http_node,
          [node/2,
          bkgnd//1,
          travel//2,
          approve//1]).
/** <module> Define a system for defining 'nodes' in a location based game
 */
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_path)).
:- use_module(library(http/js_write)).
:- use_module(library(http/html_head)).

:- use_module(journey, [loc/3]).

%!  node(-Cmds:list) is nondet
%
%   @arg Name name of the node
%   @arg Cmds bhgl commands
%
%  Define a node (usually called as directive)
%
%   $ name/1
%   : must be first, is the name of the node. Node is at /game/<Name>
%   $ <html>
%   : Any termerized html suitable for html//1
%   $ \bkgnd()
%   : I is a path to the background image
%   $ \travel(Target, Node)
%   : when you travel to target Target you will be moved to node Node
%   $ \approve(Name)
%   : poll waiting until you're 'approved' - will have a special uri to
%     approve. Start with shelling into the server and cli approval.
:- html_meta(node(-, html)).

node(Name, Cmds) :-
    b_setval(node_name, Name),
    atom_concat(Name, '_handler', HandlerName),
    HandlerHead =.. [HandlerName, _],
    cmds_handler(Cmds, HandlerBody),
    writeln(':-'(HandlerHead, HandlerBody)),
    writeln(http_handler(game(Name), HandlerName, [id(Name)])).

:- meta_predicate cmds_handler(+, -).

cmds_handler(Cmds,
             reply_html_page(game,
                             title(Title),
                             Cmds)) :-
    b_getval(node_name, Title).


bkgnd(Img) -->
    { http_absolute_location(Img, Loc, []) },
    html(img([class(background), src(Loc)], [])).

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
