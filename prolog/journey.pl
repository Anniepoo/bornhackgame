:- module(journey, [
          loc/3]).


:- use_module(library(http/http_server)).
:- use_module(library(http/html_write)).
:- use_module(library(http/html_head)).

:- use_module(http_node).

:- multifile loc/3.

% hardware folks at Bornhack
% Thomas
% Hackmeister.dk
%

loc(tkkrlab, "Tkkrlab- home of wizards", ll(55.38884524, 9.9404279)).
loc(toilet, "toilet", ll(55.3883914, 9.9400427)).
loc(test, "test location", ll(55.3888, 9.405)).
loc(foo, "foo location", ll(55.3887, 9.9402)).
loc(start, "start location", ll(55.3812, 9.9103)).

:-html_meta(node(+, +, html)).

node(Name, Desc, AddlHTML) :-
    http_handler(game(Name),
                 node_handler(Name, Desc, AddlHTML),
                 [id(Name)]).


:- html_meta node_handler(+, +, html, +).

node_handler(Name, Desc, AddlHTML, _Request) :-
    reply_html_page(
        game,
        title(Name),
        [\html_requires('/css/style.css'),
         div(id(playarea), div(id(playcontent), [
         h1(Desc),
         p(id(username), ''),
         \includemore(AddlHTML),
        p(id(coords), '...loading...')]))]).

/*
includemore(H) -->
    {strip_module(H, _, P)},
    html(P). */
includemore(H, A, B) :-
    strip_module(H, M, P),
    @(html(P, A, B), M).

:- node(foo, "You are at the big sign that says FOO",
        \travel(tkkrlab, tkkrlab)).
:- node(start,
        "start- You feel an urge to go to the pooper or Tkkrlab",
        [\travel(tkkrlab, tkkrlab), \travel(toilet, toilet)]).
:- node(tkkrlab, "You are at Tkkrlab",
        [\travel(test, test), \travel(toilet, toilet)]).
:- node(test, "You are at Test",
        [\travel(start, start), \travel(toilet, toilet)]).
:- node(toilet, "You are at the pooper",
        \travel(tkkrlab, tkkrlab)).

% if you are at a target it should call in when you leave.
% need to design this.
% in

/*
:-node([name('.'),
      \bkgnd(img('gameintro.png')),
      h1('Before it Starts...'),
      p('You are in the land of the Danes, in a field, on a cold, rainy summer day. The field has surprisingly good internet.'),
      p('You feel a trembling in your nether regions'),
      \travel(toilet, toilet)
     ]).
:-node([name(toilet),
      \bkgnd(img('toilet.png')),
      h1('The Throne of Justice'),
      p('As you sit on the throne of justice, you contemplate your life.'),
      p(i('Is being a Sharepoint developer all there is to life? Is there more?')),
      p('Then you feel a rumbling, deep in your bowels - and you know - you really know, you feel your destiny! You must become a wizard!'),
      p('You know it will be difficult. The dangers of the wizard\'s way are legendary. The path is long.'),
      p(['But', b('how to start?')]),
      p('You must find a powerful wizard to guide you'),
      p('Would it be easier to go get a beer instead?'),
      p('You rise, wipe your bum, and emerge refreshed. Ready for a new beginning. For this is only the Prolog.'),
      \travel(tkkrlab, findwizard)
      ]).
:-node([name(findwizard),
      \bkgnd(img('neutral.png')),
      h1('The Wizard of Prolog'),
      p('You sense an immense power. 110 Volts.'),
      % Annie comes out as the wizard of swi-prolog
      \approve(questdelivered)
     ]).
% Hail seeker.
% Annie appears and announces that the most important part of being a
% wizard is to have the 'four appurtenances', each bearing a sacred
% symbol.
% I have been cursed by the false wizard, and am unable to utter the
% names of the sacred symbols or wear the appurtanences.
% But if you return, suitably attired, I will greet you as a fellow
% wizard.
%
:-node([name(questdelivered),
      h1(class(blinking), 'WARNING'),
      h2(\player_name),
      p('Server BX321-4B has failed.'),
      p('todo'),
      p('The Wizard of Prolog\'s final words are burned into your mind.'),
      p(['Oh,', \player_name, '(for this is the wizard name she has given you)',
         'Go forth.'])
      ]).  % todo when quests worked out
% intro you need a hat, staff, wand, and amulet, here's some clues
%


*/

