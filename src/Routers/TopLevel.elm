module Routers.TopLevel exposing (delta2url, location2messages)

import String
import Dict exposing (Dict)
import Http
import Navigation exposing (Location)
import RouteUrl exposing (HistoryEntry(..), UrlChange)
import Erl
import Types exposing (Page(..), AuthError(..))
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

        MyAccount ->
            Just <| UrlChange NewEntry "/#app/my-account"

        _ ->
            Just <| UrlChange NewEntry "/#404"


{- TODO check token against Local Storage value:
-}
validateCrsfToken : String -> Bool
validateCrsfToken token =
    True


validAuthQuery : Dict String String -> Bool
validAuthQuery query =
    case Dict.get "state" query of
        Just state ->
            if String.slice 0 5 state == "csrf-"
            then
                validateCrsfToken <| String.dropLeft 5 state
            else
                False

        Nothing ->
            False


{-| query returned from a successful Google Auth request looks like this:
    state=csrf-Fri6wwWB20SdHyV0IbQEj42j8GM4PXEY3T48MmjE
    code=4/4NDJhDMlC2Uv-kZXUWLE2yrLIWiWleVH0tVXcbdd414
    authuser=0
    hd=kentfieldschools.org
    session_state=d71c8e092aa6049d03ecfaa25b11eef1681b99dd..db44
    prompt=consent
-}
decodeAuthCode : Dict String String -> Result AuthError String
decodeAuthCode query =
    case Dict.get "code" query of
        Just code ->
            if validAuthQuery query
            then
                Ok code
            else
                Err CSRForgery

        Nothing ->
            Err CodeMissing


location2messages : Location -> List Msg
location2messages location =
    let
        erl = Erl.parse location.href
        authCode = decodeAuthCode erl.query
        messages =
            case authCode of
                Ok code ->
                    [ ExchangeOAuthToken <| Debug.log "xchg code" code ]

                Err _ ->
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
