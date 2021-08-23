:- module(bornhack_game, [go/0]).
/** <module>  BornHack 2021 Location Based Game
 *
  */

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_session)).
:- use_module(library(http/js_write)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_ssl_plugin)).
:- use_module(library(http/http_files)).

user:file_search_path(library, Identity) :-
    getenv('HOME', Home),
    format(atom(Identity), '~w/identity/prolog', [Home]).

:- use_module(library(identity/identity)).
:- use_module(library(identity/login_database), [use_default_db/0,
                                                current_user//0,
                                                retractall_user_property/2]).
:- use_module(library(identity/login_static)).

:- use_module(library(settings)).

:- ensure_loaded(pages).

go :-
    load_settings('settings.db'),
    current_prolog_flag(version, X),
    X >= 80100,
    use_default_db,
    http_set_session_options(
        [ create(noauto),
          timeout(1800)  % 30 minutes
       %   ,ssl([
        %      certificate_file('/etc/letsencrypt/live/partyserver.rocks/cert.pem'),
         %       key_file('/etc/letsencrypt/live/partyserver.rocks/privkey.pem')
          %                ])
        ]),
    http_server(http_dispatch, [port(5000)]).
go :-
    writeln('Need to be on SWI-Prolog 8.1.0 or better, you are on'),
    version.

user:file_search_path(js, 'web/js').
user:file_search_path(css, 'web/css').
user:file_search_path(img, 'web/icons').
user:file_search_path(html, 'web/html').
user:file_search_path(fonts, 'web/fonts').

http:location(js, '/js', []).
http:location(img, '/icons', []).
http:location(css, '/css', []).
http:location(html, '/html', []).
http:location(fonts, '/font', []).


:- http_handler(html(.), http_reply_from_files(html(.), []), [prefix]).

:- http_handler(img(.), http_reply_from_files(img(.), []), [prefix]).

:- http_handler(js(.), http_reply_from_files(js(.), []), [prefix]).

:- http_handler(fonts(.), http_reply_from_files(fonts(.), []), [prefix]).

:- http_handler(css(.), http_reply_from_files(css(.), []), [prefix]).



:- set_setting(identity:constraints,
    _{
        email: _{ min: 4,
                  max: 128,
                  regex: '^[A-Za-z0-9\\-_\\+\\.]+@(([A-Za-z0-9\\-_\\+]+)\\.)+[A-Za-z0-9]+$',
                  warn: 'Must vaguely look like an email address'
                },
        uname: _{ min: 4,
                  max: 128,
                  regex: '^[A-Za-z0-9\\-_\\+\\.]{4,128}$',
                  warn: 'User name must be 4-128 characters from a-z, A-Z, 0-9, - and _'
                },
        passwd: _{ min: 4,
                   max: 999,
                   regex: '^.{8,999}$',
                   warn:  'Password must be at least 8 long'
                 },
        passwd2: _{
                     min: 4,
                     max: 999,
                     regex: '^.{8,999}$',
                     warn: 'Field below must match password'
                 }
    }).




















