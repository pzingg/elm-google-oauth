module Main exposing (main)

import RouteUrl exposing (program)
import Model exposing (Model)
import Update exposing (init, update)
import View exposing (view)
import Routers.TopLevel as TL


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


main : Program Never
main =
    RouteUrl.program
        { delta2url = TL.delta2url
        , location2messages = TL.location2messages
        , init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
