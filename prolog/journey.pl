:- module(journey, []).

:- multifile loc/2.

% Thomas
% Hackmeister.dk
%

loc(tkkrlab, "Tkkrlab- home of wizards", box(-1,-2,1,2)).
loc(toilet, todo).

%!  node(-Cmds:list) is nondet
%
%   @arg Name name of the node
%   @arg Cmds bhgl commands
%
%   $ name/1
%   : must be first, is the name of the node. Node is at /game/<Name>
%   $ <html>
%   : Any termerized html suitable for html//1
%   $ bkgnd()
%   : I is a path to the background image
%   $ travel(Target, Node)
%   : when you travel to target Target you will be moved to node Node
%   $ approve(Name)
%   : poll waiting until you're 'approved' - will have a special uri to
%     approve. Start with shelling into the server and cli approval.
node([name('.'),
      bkgnd(img('gameintro.png')),
      h1('Before it Starts...'),
      p('You are in the land of the Danes, in a field, on a cold, rainy summer day. The field has surprisingly good internet.'),
      p('You feel a trembling in your nether regions'),
      travel(toilet, toilet)
     ]).
node([name(toilet),
      bkgnd(img('toilet.png')),
      h1('The Throne of Justice'),
      p('As you sit on the throne of justice, you contemplate your life.'),
      p(i('Is being a Sharepoint developer all there is to life? Is there more?')),
      p('Then you feel a rumbling, deep in your bowels - and you know - you really know, you feel your destiny! You must become a wizard!'),
      p('You know it will be difficult. The dangers of the wizard\'s way are legendary. The path is long.'),
      p(['But', b('how to start?')]),
      p('You must find a powerful wizard to guide you'),
      p('Would it be easier to go get a beer instead?'),
      p('You rise, wipe your bum, and emerge refreshed. Ready for a new beginning. For this is only the Prolog.'),
      travel(tkkrlab, findwizard)
      ]).
node([name(findwizard),
      h1('The Wizard of Prolog'),
      p('You sense an immense power. 110 Volts.'),
      % Annie comes out as the wizard of swi-prolog
      approve(questdelivered)
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
node([name(questdelivered),
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




