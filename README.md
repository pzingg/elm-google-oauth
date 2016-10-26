# elm-google-oauth

An attempt to use some "extended Elm Architecture" practices, namely:

* TopLevel and Authenticates routers from [@ohanhi's talk at Elm Conf 2016](https://github.com/dailydrip/elmconf-2016#beyond-hello-world-and-todo-lists---ossi-hanhinen)
* [Configuration from .js port or from statically served .json files](https://www.reddit.com/r/elm/comments/3u7u7w/injecting_config_into_elm_code/)
* More...

## Dependencies, frequently used libraries

* https://github.com/elm-lang/navigation
* https://github.com/ccapndave/elm-update-extra

## Related projects found on the web:

* Parse backend JSON data: https://github.com/ohanhi/elm-web-data
* Elm + OAuth: https://github.com/kmaida/auth0-elm-with-jwt-api
* Forms, paginated API results: https://github.com/knewter/time-tracker
* Lens, access and update deeply nested models: https://github.com/arturopala/elm-monocle

## Common structural practices in Elm:

Define source files that appear in most larger projects:

* Routers/\*.elm
* Types.elm
* Decoders.elm
* Model.elm
* Ports.elm
