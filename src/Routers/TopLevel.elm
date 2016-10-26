module Routers.TopLevel exposing (delta2url, location2messages)

import Navigation exposing (Location)
import RouteUrl exposing (HistoryEntry(..), UrlChange)
import Types exposing (Page(..))
import Model exposing (Model)
import Update exposing (Msg(..))
import Routers.Utils exposing (hash2list)
import Routers.Authenticated as AR


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    case current.activePage of
        Home ->
            Just <| UrlChange NewEntry "/"

        Login ->
            Just <| UrlChange NewEntry "/#login"

        Logout ->
            Just <| UrlChange NewEntry "/#app/logout"

        MyAccount ->
            Just <| UrlChange NewEntry "/#app/my-account"

        _ ->
            Just <| UrlChange NewEntry "/#404"


location2messages : Location -> List Msg
location2messages location =
    let
        route = hash2list "#!/" location.hash

    in
        route2messages route


route2messages : List String -> List Msg
route2messages route =
        case Debug.log "route" route of
            "" :: _ ->
                [ SetActivePage Home ]

            "login" :: _ ->
                [ SetActivePage Login ]

            "app" :: xs ->
                AR.route2messages xs

            _ ->
                [ SetActivePage PageNotFound ]
