:- module(pages, []).

:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_session)).
:- use_module(library(http/js_write)).
:- use_module(library(http/http_json)).
:- use_module(library(identity/login_database)).
:- use_module(library(http/html_head)).
:- use_module(library(http/http_parameters)).
:- use_module(home).

		 /*******************************
		 *            Resources       *
		 *******************************/


:- html_resource(style, [virtual, mime_type(text/css),
                         requires('css/style.css')]).

:- html_resource('/js/location.js', [mime_type(text/javascript)]).

:- html_resource('/js/identity.js', [mime_type(text/javascript)]).


		 /*******************************
		 *      Pages               *
		 *******************************/
/*
:- multifile user:head//2.

user:head(X, Head) -->
    {gtrace},
    html(head([meta([name(viewport), content('width=device-width, initial-scale=1.0')], []) |
                Head])).
*/

:- http_handler(root(admin), admin_handler, [id(admin)]).


admin_handler(_Request) :-
      reply_html_page(
          screen,
          title('Colossal Hack'),
          \admin_page).

:- html_meta(bezel(html, ?, ?)).

bezel(Content) -->
    html(div(id(bezel), Content)).

admin_page -->
    html_requires(style),
    html(
        div(id(screen),
            \bezel(\content)
           )).

:- http_handler(root(ajax), ajax_handler, [id(ajax), role(user)]).

ajax_handler(_Request) :-
    reply_json_dict(_{
                        displaytext: 'AJAX fetched me correctly'
                    }).

:- http_handler(root(foo/A/B), dani_handler(A, B), []).

dani_handler(A, B, _Request) :-
    reply_json_dict(_{
                        a: A,
                        b: B
                    }).


		 /*******************************
		 *  User moved   *
		 *******************************/
:- http_handler(root(loc), loc_handler, [id(loc)]).

loc_handler(Request) :-
    http_parameters(
        Request,
        [   user(User, []),
            lat(Lat, [float]),
            long(Long, [float])
        ]),
    debug(loc(parms), 'user ~w lat ~w long ~w', [User, Lat, Long]),
    latlong_uv(latlong(Lat, Long), uv(U, V)),
    user_property(User, username(Name)),
    format(string(S), 'user ~w lat ~w long ~w u ~w v ~w', [Name, Lat, Long, U, V]),
    reply_json_dict(_{
                        display: S
                    }).

latlong_uv(latlong(Lat, Long), uv(U, V)) :-
    U is floor((Lat - 55.3884917) / 0.00008),
    V is floor((Long - 9.9402879) / 0.00005).

		 /*******************************
		 *       Generate User IDs
		 *******************************/


:- http_handler(root(getid) ,
                getid_handler,
                [id(getid_handler)]).

getid_handler(_Request) :-
    create_user(ID),
    create_username(Name),
    set_user_property(ID, username(Name)),
    reply_json_dict(_{
                       identity: ID,
                       username: Name
                    }).

create_user(ID) :-
    uuid(ID).

create_username(Name) :-
    prop_names(PN),
    qualities(Q),
    random_member(PropName, PN),
    random_member(Quality, Q),
    append([PropName, ` the `, Quality], Code),
    string_codes(Name, Code),
    \+ user_property(_, username(Name)).

prop_names([`Arnold`, `Betty`, `Carl`, `Doofus`, `Earl`,
          `Floyd`, `Günther`, `Hans`, `Ingrid`, `Johan`,
          `Bübba`, `Kushboo`, `Lemonade`, `Otopöpø`,
          `Poobah`, `Quax`, `Rohan`, `Smoochie`, `Türin`,
          `Uvula`, `Veritas`, `Prospero`, `Xugyrius`,
           `Yendor`, `Zymax`]).

qualities([`Amiable`, `Blepharious`, `Confident`, `Dork`,
           `Earnest`, `Foobaric`, `Garbage Collecter`,
           `Hospitable`, `Idler`, `Mendacious`, `Ruminant`,
           `Jr Dev`, `Optional`, `Insignificant`, `Sane`,
           `Unsteady`, `Flatulent`, `Billious`, `Calm`,
           `Effervescent`, `Drunkard`, `Fearless`, `Steadfast`,
           `Questionable`, `Domestic`, `Fairly Decent Looking`,
           `Normal`, `Sometimes Helpful`, `Handy`, `Chicken Farmer`,
           `Vogon`, `Woolgatherer`]).







