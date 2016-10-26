module Routers.TopLevel exposing (delta2url, location2messages)

import String
import Dict exposing (Dict)
import Http
import Navigation exposing (Location)
import RouteUrl exposing (HistoryEntry(..), UrlChange)
import Erl
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



{-| query returned from a successful Google Auth request looks like this:

 state=csrf%20Fri6wwWB20SdHyV0IbQEj42j8GM4PXEY3T48MmjE
 code=4/4NDJhDMlC2Uv-kZXUWLE2yrLIWiWleVH0tVXcbdd414
 authuser=0
 hd=kentfieldschools.org
 session_state=d71c8e092aa6049d03ecfaa25b11eef1681b99dd..db44
 prompt=consent

-}
decodeCrsfToken : Dict String String -> Maybe String
decodeCrsfToken query =
    let
        maybeState = Dict.get "state" query
        maybeToken =
            case maybeState of
                Just state ->
                    if String.slice 0 5 state == "csrf+"
                    then
                        Just <| String.dropLeft 5 state
                    else
                        Nothing

                Nothing ->
                    Nothing
    in
        maybeToken


decodeAuthCode : Dict String String -> Maybe String
decodeAuthCode query = Dict.get "code" query


location2messages : Location -> List Msg
location2messages location =
    let
        erl = Erl.parse location.href
        csrfToken = decodeCrsfToken erl.query
        authCode = decodeAuthCode erl.query
        messages =
            case authCode of
                Just code ->
                    case csrfToken of
                        Just token ->
                            {- TODO: check against token in local storage -}
                            [ ExchangeOAuthToken <| Debug.log "xchg code" code ]

                        Nothing ->
                            route2messages <| hash2list "#!/" location.hash

                Nothing ->
                    route2messages <| hash2list "#!/" location.hash

    in
        messages


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
