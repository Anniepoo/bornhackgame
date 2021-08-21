:- module(pages, []).

:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_session)).
:- use_module(library(http/js_write)).
:- use_module(library(http/http_json)).
:- use_module(library(identity/customize)).
:- use_module(library(identity/login_database)).
:- use_module(library(http/html_head)).
:- use_module(library(http/http_parameters)).


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


:- html_resource(style, [virtual, mime_type(text/css),
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
          title(\local('Colossal Hack')),
          \home_page).


content -->
    html([
        h1(class(title), 'Colossal Hack'),
        p(id(fstatus), '...loading...'),
        a([id('fmap-link'),target('_blank')], ''),
        p(id(username), '...loading...'),
        p(id(coords), '...coords loading...'),
        \js_script({|javascript(_)||

var identity = localStorage.getItem("bornhackgameid");
var display_name = localStorage.getItem("bornhackgameusername");
var n = 0;
                    var in_process = false;

                    var latmin = -10000.0;
                    var latmax = -10000.0;
                    var longmin = -10000.0;
                    var longmax = -10000.0;

if (!identity) {
       fetch("/getid").then(function(response) {
                             return response.json();
                         })
                       .then(function(myJson) {
                                 localStorage.setItem("bornhackgameid", myJson.identity);
                                 localStorage.setItem("bornhackgameusername", myJson.username);
                                 identity = myJson.identity;
                                 display_name = myJson.username;
                                 document.getElementById("username").innerHTML = display_name;
                             });
   } else {
      document.getElementById("username").innerHTML = display_name;
   }

function follow_success(position) {
  const status = document.querySelector('#fstatus');
  const mapLink = document.querySelector('#fmap-link');

    status.textContent = '';
    const latitude  = position.coords.latitude;
    const longitude = position.coords.longitude;

    mapLink.href = `https://www.openstreetmap.org/#map=18/${latitude}/${longitude}`;
    mapLink.textContent = `${n}  Latitude: ${latitude} °, Longitude: ${longitude} °`;

   if (!in_process && (latitude < latmin || latitude > latmax ||
       longitude < longmin || longitude > longmax)) {
          in_process = true;
               fetch(`/loc?user=${identity}&lat=${latitude}&long=${longitude}`)
          .then(function(response) {
                             return response.json();
                         })
                       .then(function(myJson) {
                                 document.getElementById("coords").innerHTML = myJson.display;
                                 in_process = false;
                                 latmin = latitude - 0.00005;
                                 latmax = latitude + 0.00005;
                                 longmin = longitude - 0.00008;
                                 longmax = longitude + 0.00008;
                                 n++
                             });

      }

}

function follow_error() {
  alert('Sorry, no position available.');
}

const options = {
  enableHighAccuracy: true,
  maximumAge: 30000,
  timeout: 27000
};

const watchID = navigator.geolocation.watchPosition(follow_success, follow_error, options);
     |})]).

:- html_meta(bezel(html, ?, ?)).

bezel(Content) -->
    html(div(id(bezel), Content)).

home_page -->
    html_requires(style),
    html(
        div(id(screen),
            \bezel(\content)
           )).


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







