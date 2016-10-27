module Routers.Authenticated exposing (route2messages)

import Types exposing (Page(..))
import Update exposing (Msg(..))


route2messages : List String -> List Msg
route2messages route =
    case route of
        [] ->
            []

        "my-account" :: [] ->
            [ SetActivePage MyAccount ]

        _ ->
            [ SetActivePage PageNotFound ]
