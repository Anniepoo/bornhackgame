:- module(pages, []).

:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_session)).
:- use_module(library(http/js_write)).
:- use_module(library(http/http_json)).
:- use_module(library(identity/customize)).
:- use_module(library(identity/login_database)).
:- use_module(library(http/html_head)).


customize:local_hook(Eng, Local) :-
    catch(
        (   current_user(UName),
            (   user_property(UName, lang(Lang))
            ;   Lang = eng
            ),
            by_lang(Lang, Eng, Local),
            !
        ),
        error(existence_error(http_session, _), _),
        Local = Eng
    ).

by_lang(eng, Eng, Eng).
by_lang(swahili, 'Baraka', 'Baraka').
by_lang(swahili, 'Sell', 'kuuza').
by_lang(swahili, 'Audit', 'ukaguzi').


by_lang(_, Eng, Eng). % must remain at bottom


		 /*******************************
		 *            Resources       *
		 *******************************/


:- html_resource(style, [virtual,
                         requires('css/style.css')]).


		 /*******************************
		 *      Pages               *
		 *******************************/
:- multifile user:head//2.

user:head(screen, Head) -->
    html(head([meta([name(viewport), content('width=device-width, initial-scale=1.0')], []) |
                Head])).


:- http_handler(root(.), root_handler, [id(home)]).
:- http_handler(root(secret), secret_handler, [id(secret), role(user)]).

root_handler(_Request) :-
      reply_html_page(
          screen,
          title(\local('Baraka')),
          \home_page).

home_page -->
    html_requires(style),
    html(
        div(id(screen),
            [
                \nav,
                \sell
            ])).

		 /*******************************
		 *            Nav              *
		 *******************************/

nav -->
    html(
        div(id(nav),
            [ \nbutton('Sell'),
              \nbutton('m-pesa'),
              \nbutton('audit')
            ])).

nbutton(Label) -->
    { nav_href(Label, HREF) },
    html(a(href(HREF), \local(Label))).

nav_href('Sell', '/').
nav_href('m-pesa', '/mpesa').
nav_href('audit', '/audit').

		 /*******************************
		 *               Sell           *
		 *******************************/

sell -->
    html([
        p(id(total), ['0 KES']),
        input([autofocus, id(price), type(number), name(item)], []),
        \keyboard]).

keyboard -->
    html(
        table(id(keyboard),
              [
            tr([
                \numbtn(7),
                \numbtn(8),
                \numbtn(9)
            ]),
            tr([
                \numbtn(4),
                \numbtn(5),
                \numbtn(6)
            ]),
            tr([
                \numbtn(1),
                \numbtn(2),
                \numbtn(3)
            ]),
            tr(\numbtn(colspan(3), 0))
        ])).

numbtn(Digit) -->
    html(td(Digit)).

numbtn(Attr, Digit) -->
    html(td(Attr, Digit)).

secret_handler(_Request) :-
      reply_html_page(
          title('Secret Page'),
          [a(href(location_by_id(home)), 'link to home page'),
           a(href(location_by_id(logout)), 'Log Out'),
           div(id(loadbyajax), 'not yet loaded by ajax'),
           p(\current_user),
           \js_script({| javascript(_) ||
     fetch("/ajax").then(function(response) {
                             return response.json();
                         })
                       .then(function(myJson) {
                                 document.getElementById("loadbyajax").innerHTML = myJson.displaytext;
                             });
              |})
          ]).

:- http_handler(root(ajax), ajax_handler, [id(ajax), role(user)]).

ajax_handler(_Request) :-
    reply_json_dict(_{
                        displaytext: 'AJAX fetched me correctly'
                    }).

