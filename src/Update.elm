module Update exposing (Msg(..), init, update, googleAuthUrl)

import Debug
import Dict
import Time exposing (Time)
import Task
import Navigation
import Erl
import Types exposing (Page(..))
import Model exposing (..)
import Tokens exposing (makeToken)
import ClientSecrets exposing (redirectURI, clientID, clientSecret, googleDomain)


type Msg
    = LogIn
    | LogOut
    | SetActivePage Page
    | SetCSRFToken Time


init : (Model, Cmd Msg)
init =
    emptyModel ! []


never : Never -> a
never n =
    never n


setCSRFToken : Cmd Msg
setCSRFToken =
    Task.perform (\_ -> Debug.crash "Time.now") SetCSRFToken Time.now


googleAuthQuery : Model -> List (String, String)
googleAuthQuery model =
    [ ( "client_id", clientID )
    , ( "response_type", "code" )
    , ( "scope", "openid email" )
    , ( "redirect_uri", redirectURI )
    , ( "state", "security_token=" ++ model.csrfToken )
    , ( "hd", googleDomain )
    ]


googleAuthUrl : Model -> String
googleAuthUrl model =
    let
        erl = Erl.parse "https://accounts.google.com/o/oauth2/v2/auth"
    in
        Erl.toString { erl | query = Dict.fromList (googleAuthQuery model) }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetCSRFToken time ->
            { model | csrfToken = makeToken time } ! []

        SetActivePage page ->
            case page of
                Home ->
                    { model | activePage = page, pageTitle = "Welcome!" } ! []
                Login ->
                    ( { model | activePage = page, pageTitle = "Login" }, setCSRFToken )
                PageNotFound ->
                    { model | activePage = page, pageTitle = "Not Found!" } ! []
                AccessDenied ->
                    { model | activePage = page, pageTitle = "Access Denied!" } ! []
                MyAccount ->
                    { model | activePage = page, pageTitle = "My Account" } ! []
                Logout ->
                    { model | activePage = page, pageTitle = "Logout" } ! []

        _ ->
            model ! []
