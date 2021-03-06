module Routers.TopLevel exposing (delta2url, location2messages)

import Dict exposing (Dict)
import String

import Erl
import Navigation exposing (Location)
import RouteUrl exposing (HistoryEntry(..), UrlChange)

import Routers.Authenticated as AR
import Routers.Utils exposing (hash2list)
import Model exposing (Model)
import Types exposing (Page(..), AuthError(..))
import Update exposing (Msg(..))


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



{-| query returned from a successful Google Auth request looks like this:
    state=csrf-Fri6wwWB20SdHyV0IbQEj42j8GM4PXEY3T48MmjE
    code=4/4NDJhDMlC2Uv-kZXUWLE2yrLIWiWleVH0tVXcbdd414
    authuser=0
    hd=kentfieldschools.org
    session_state=d71c8e092aa6049d03ecfaa25b11eef1681b99dd..db44
    prompt=consent
-}
query2messages : Dict String String -> List Msg
query2messages query =
    let
        maybeCode = Dict.get "code" query
        maybeState = Dict.get "state" query
        maybeToken =
            case maybeState of
                Just state ->
                    if String.slice 0 5 state == "csrf-"
                    then
                        Just (String.dropLeft 5 state)
                    else
                        Nothing

                Nothing ->
                    Nothing
    in
        [ ExchangeOAuthToken maybeToken maybeCode ]


hasOAuthResponseParams : Dict String String -> Bool
hasOAuthResponseParams query =
    Dict.member "state" query && Dict.member "code" query


location2messages : Location -> List Msg
location2messages location =
    let
        erl = Erl.parse location.href
        query = erl.query
    in
        if hasOAuthResponseParams query
        then
            query2messages query
        else
            route2messages <| hash2list "#!/" location.hash


route2messages : List String -> List Msg
route2messages route =
        case Debug.log "route" route of
            "" :: _ ->
                [ SetActivePage Home ]

            "login" :: _ ->
                [ SetActivePage Login
                , StoreCSRFToken
                ]

            "app" :: xs ->
                AR.route2messages xs

            _ ->
                [ SetActivePage PageNotFound ]
