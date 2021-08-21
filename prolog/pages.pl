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
          title(\local('Colossal Hack')),
          \home_page).


content -->
    html([
        h1(class(title), 'Colossal Hack'),
        button(id('find-me'), 'Hello out there'),
        br([]),
        h2(button),
        p(id(status), ''),
        a([id('map-link'),target('_blank')], ''),
        h2(follow),
        p(id(fstatus), ''),
        a([id('fmap-link'),target('_blank')], ''),
        \js_script({|javascript(_)||
function follow_success(position) {
  const status = document.querySelector('#fstatus');
  const mapLink = document.querySelector('#fmap-link');

    status.textContent = '';
    const latitude  = position.coords.latitude;
    const longitude = position.coords.longitude;

    mapLink.href = `https://www.openstreetmap.org/#map=18/${latitude}/${longitude}`;
    mapLink.textContent = `Latitude: ${latitude} °, Longitude: ${longitude} °`;

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

function geoFindMe() {

  const status = document.querySelector('#status');
  const mapLink = document.querySelector('#map-link');

  mapLink.href = '';
  mapLink.textContent = '';

  function success(position) {
    const latitude  = position.coords.latitude;
    const longitude = position.coords.longitude;

    status.textContent = '';
    mapLink.href = `https://www.openstreetmap.org/#map=18/${latitude}/${longitude}`;
    mapLink.textContent = `Latitude: ${latitude} °, Longitude: ${longitude} °`;
  }

  function error() {
    status.textContent = 'Unable to retrieve your location';
  }

  if(!navigator.geolocation) {
    status.textContent = 'Geolocation is not supported by your browser';
  } else {
    status.textContent = 'Locating…';
    navigator.geolocation.getCurrentPosition(success, error);
  }

}

document.querySelector('#find-me').addEventListener('click', geoFindMe);

                   |})
                   ]).

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











