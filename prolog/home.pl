:- module(home, [
              content//0
          ]).

:- use_module(library(http/html_write)).
:- use_module(library(http/http_session)).
:- use_module(library(http/js_write)).
:- use_module(library(http/http_json)).

content -->
    html([
        h1(class(title), 'Colossal Hack'),
        p(id(fstatus), '...loading...'),
        a([id('fmap-link'),target('_blank')], ''),
        p(id(username), '...loading...'),
        p(id(coords), '...coords loading...'),
        p(a([id(startgame), href('')], 'Start Game')),
        script(src('/js/identity.js'), []),
        script(src('/js/location.js'), [])
    ]).

