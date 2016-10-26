module Update exposing (Msg(..), init, update, googleAuthUrl)

import Debug
import Dict
import Time exposing (Time)
import Task
import Json.Encode as JE
import Http
import Erl
import RemoteData exposing (WebData)
import Types exposing (Page(..), OAuthToken)
import Decoders exposing (decodeOAuthToken)
import Model exposing (..)
import Tokens exposing (makeToken)
import ClientSecrets exposing (redirectURI, clientID, clientSecret, googleDomain)


type Msg
    = LogIn
    | LogOut
    | SetActivePage Page
    | SetCSRFToken Time
    | ExchangeOAuthToken String
    | OAuthTokenResponse (WebData OAuthToken)


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
    , ( "state", "csrf " ++ model.csrfToken )
    , ( "hd", googleDomain )
    ]


googleAuthUrl : Model -> String
googleAuthUrl model =
    let
        erl = Erl.parse "https://accounts.google.com/o/oauth2/v2/auth"
    in
        Erl.toString { erl | query = Dict.fromList (googleAuthQuery model) }


googleExchangeTokenBody : String -> Http.Body
googleExchangeTokenBody code =
    let
        s = "code=" ++ code ++
            "&client_id=" ++ clientID ++
            "&client_secret=" ++ clientSecret ++
            "&redirect_uri=" ++ redirectURI ++
            "&grant_type=authorization_code"
    in
        Debug.log "body" <| Http.string s

googleExchangeTokenUrl : String
googleExchangeTokenUrl = "https://www.googleapis.com/oauth2/v4/token"


-- Http.post : Decoder value -> String -> Body -> Task Error value
-- RemoteData.asCmd : Task e a -> Cmd (RemoteData e a)
exchangeToken : String -> Http.Body -> Cmd Msg
exchangeToken url body =
    Http.post decodeOAuthToken url body
        |> RemoteData.asCmd
        |> Cmd.map OAuthTokenResponse


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetCSRFToken time ->
            { model | csrfToken = makeToken time } ! []

        ExchangeOAuthToken code ->
            ( model, exchangeToken googleExchangeTokenUrl (googleExchangeTokenBody code))

        OAuthTokenResponse response ->
            ( { model | oauthToken = Debug.log "oauth" response }, Cmd.none )

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
