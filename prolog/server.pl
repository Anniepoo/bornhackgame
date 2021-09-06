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

:- use_module(database, [use_default_db/0, retractall_user_property/2]).
:- use_module(library(settings)).

:- ensure_loaded(pages).

:- ensure_loaded(journey).

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
http:location(fonts, '/fonts', []).
http:location(game, '/game', []).


:- http_handler(html(.), http_reply_from_files(html(.), []), [prefix]).

:- http_handler(img(.), http_reply_from_files(img(.), []), [prefix]).

:- http_handler(js(.), http_reply_from_files(js(.), []), [prefix]).

:- http_handler(fonts(.), http_reply_from_files(fonts(.), []), [prefix]).

:- http_handler(css(.), http_reply_from_files(css(.), []), [prefix]).







