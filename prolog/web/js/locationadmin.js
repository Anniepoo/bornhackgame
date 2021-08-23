
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