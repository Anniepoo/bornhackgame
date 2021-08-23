// establish the users identity

var identity = localStorage.getItem("bornhackgameid");
var display_name = localStorage.getItem("bornhackgameusername");

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