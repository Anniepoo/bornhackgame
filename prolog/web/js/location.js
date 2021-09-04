
// for debug, number of times we've called server
var n = 0;

// box - if we step outside this box we report to server and
// move the box
var latmin = -10000.0;
var latmax = -10000.0;
var longmin = -10000.0;
var longmax = -10000.0;

var targets = Array();

function at_target(Lat, Long, Target) {
  // 3.03 is cos(55deg)^2
  const rsq = 111195.0 * 111195.0 * ((Lat - Target.latitude) * (Lat - Target.latitude) +
    (Long - Target.longitude) * (Long - Target.longitude) * 0.32);
  console.log(rsq);

  document.getElementById('loc').innerHTML = rsq.toString() +
    " " + Target.latitude.toString() + " " + rsq.longitude.toString();

  return rsq < 25.0; // 5 meters
}

function follow_success(position) {
  const latitude = position.coords.latitude;
  const longitude = position.coords.longitude;

  // see if we hit a target
  for (target of targets) {
    if (at_target(latitude, longitude, target)) {
      in_process = true;
      document.location.href =
        `/game/${target.target}?user=${identity}`;
    }
  }

  // if not, are we eligible for wizard's battle?
  if (!in_process && (latitude < latmin || latitude > latmax ||
    longitude < longmin || longitude > longmax)) {
    in_process = true;
    fetch(`/loc?user=${identity}&lat=${latitude}&long=${longitude}`)
      .then(function (response) {
        return response.json();
      })
      .then(function (myJson) {
        var coords = document.getElementById("coords");
        if (coords) {
          document.getElementById("coords").innerHTML = myJson.display;
        }
        in_process = false;
        latmin = latitude - 0.00005;
        latmax = latitude + 0.00005;
        longmin = longitude - 0.00008;
        longmax = longitude + 0.00008;
        n++
      });
  }
}

var gps_console_warn = false;

function follow_error() {
  if (!gps_console_warn) {
    alert('Sorry, no position available. You will need GPS to play this game');
    gps_console_warn = true;
  }
}

const options = {
  enableHighAccuracy: true,
  maximumAge: 30000,
  timeout: 27000
};

const watchID = navigator.geolocation.watchPosition(follow_success, follow_error, options);