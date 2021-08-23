
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
  document.getElementById('loc').innerHTML = rsq.toString();
  return rsq < 25.0; // 5 meters
}

function follow_success(position) {
  const latitude = position.coords.latitude;
  const longitude = position.coords.longitude;

  for (target of targets) {
    if (at_target(latitude, longitude, target)) {
      in_process = true;
      document.location.href =
        `/game/${target.target}?user=${identity}`;
    }
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