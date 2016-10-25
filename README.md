# elm-google-oauth

An attempt to use some "extended Elm Architecture" practices, namely:

* TopLevelRouter and AppRouter from [@ohanhi's talk at Elm Conf 2016](https://github.com/oldfartdeveloper/elm-conf-2016-notes/blob/master/BigElmApps.md)
* [Configuration from .js port or from statically served .json files](https://www.reddit.com/r/elm/comments/3u7u7w/injecting_config_into_elm_code/)
* More...

## Dependencies, frequently used libraries

* https://github.com/elm-lang/navigation
* https://github.com/ccapndave/elm-update-extra

## Related projects found on the web:

* Elm + OAuth: https://github.com/kmaida/auth0-elm-with-jwt-api
* Forms, paginated API results: https://github.com/knewter/time-tracker
* Lens, access and update deeply nested models: https://github.com/arturopala/elm-monocle

## Common structural practices in Elm:

Define source files that appear in most larger projects:

* Types.elm
* Decoders.elm
* Model.elm
* Ports.elm
