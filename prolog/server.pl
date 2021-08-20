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
          timeout(1800)  % half hour sessions
       %   ,ssl([
        %      certificate_file('/etc/letsencrypt/live/partyserver.rocks/cert.pem'),
         %       key_file('/etc/letsencrypt/live/partyserver.rocks/privkey.pem')
          %                ])
        ]),
    http_server(http_dispatch, [port(5000)]).
go :-
    writeln('Need to be on SWI-Prolog 8.1.0 or better, you are on'),
    version.


:- http_handler('/html/', http_reply_from_files('../web/html/', []), [prefix]).

:- http_handler('/img/', http_reply_from_files('../web/img/', []), [prefix]).

:- http_handler('/js/', http_reply_from_files('../web/js/', []), [prefix]).

:- http_handler('/font/', http_reply_from_files('../web/fonts/', []), [prefix]).

:- http_handler('/css/', http_reply_from_files('../web/css/', []), [prefix]).

