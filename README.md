# elm-google-oauth

An attempt to use some "extended Elm Architecture" practices, namely:

* TopLevel and Authenticated routers from [@ohanhi's talk at Elm Conf 2016](https://github.com/dailydrip/elmconf-2016#beyond-hello-world-and-todo-lists---ossi-hanhinen)
* [Configuration from .js port or from statically served .json files](https://www.reddit.com/r/elm/comments/3u7u7w/injecting_config_into_elm_code/)
* More...

## Dependencies, frequently used libraries

* https://github.com/evancz/elm-http
* https://github.com/sporto/erl
* https://github.com/krisajenkins/remotedata
* https://github.com/elm-lang/navigation
* https://github.com/rgrempel/elm-route-url

## Related projects found on the web:

* Parse backend JSON data: https://github.com/krisajenkins/remotedata
* Elm + Auth0: https://github.com/kmaida/auth0-elm-with-jwt-api
* Forms, paginated API results: https://github.com/knewter/time-tracker
* Lenses to access and update data members in deeply nested models: https://github.com/arturopala/elm-monocle

## Common structural practices in Elm:

Define source files that appear in most larger projects:

* Routers/\*.elm
* Types.elm
* Decoders.elm
* Model.elm
* Ports.elm
