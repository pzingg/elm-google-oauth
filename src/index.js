require('./main.css');
require("./pomegranate.jpg");

var Elm = require('./Main.elm');

var root  = document.getElementById('root');

var app = Elm.Main.embed(root);

// Port to change location from Elm via a Cmd, because Material module buttons
// can't have href's yet, and because changing URL in Navigation module
// outside the current path is forbidden.
app.ports.externalHref.subscribe(function(href) {
    window.location.href = href;
});
