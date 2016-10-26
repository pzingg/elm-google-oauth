module Update exposing (Msg(..), init, update, googleAuthUrl)

import Debug
import String
import Dict
import Time exposing (Time)
import Task exposing (Task)
import Http
import Json.Decode as JD
import Erl
import RemoteData exposing (WebData)
import Types exposing (Page(..), OAuthToken)
import Decoders exposing (decodeOAuthToken)
import Model exposing (..)
import Tokens exposing (makeToken)
import ClientSecrets exposing (redirectURI, clientID, clientSecret, googleDomain)


-- MESSAGES


type Msg
    = LogIn
    | LogOut
    | SetActivePage Page
    | SetCSRFToken Time
    | ExchangeOAuthToken String
    | OAuthTokenResponse (WebData OAuthToken)


-- HELPERS


never : Never -> a
never n =
    never n


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
        s = String.join "&"
            [ "code=" ++ code
            , "client_id=" ++ clientID
            , "client_secret=" ++ clientSecret
            , "redirect_uri=" ++ redirectURI
            , "grant_type=authorization_code"
            ]
    in
        Http.string s


googleExchangeTokenUrl : String
googleExchangeTokenUrl = "https://www.googleapis.com/oauth2/v4/token"


postFormUrlEncoded : JD.Decoder value -> String -> Http.Body -> Task.Task Http.Error value
postFormUrlEncoded decoder url body =
  let request =
    { verb = "POST"
    , headers =
        [ ("Content-Type", "application/x-www-form-urlencoded")
        -- , ("Origin", "http://localhost:3000")
        -- , ("Access-Control-Request-Method", "POST")
        -- , ("Access-Control-Request-Headers", "X-Custom-Header")
        ]
    , url = url
    , body = body
    }

  in
      Http.fromJson decoder (Http.send Http.defaultSettings request)


-- COMMANDS


setCSRFToken : Cmd Msg
setCSRFToken =
    Task.perform never SetCSRFToken Time.now


exchangeToken : String -> Http.Body -> Cmd Msg
exchangeToken url body =
    postFormUrlEncoded decodeOAuthToken url body
        |> RemoteData.asCmd
        |> Cmd.map OAuthTokenResponse


-- INIT


init : (Model, Cmd Msg)
init =
    emptyModel ! []


-- UPDATE


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetCSRFToken time ->
            { model | csrfToken = makeToken time } ! []

        ExchangeOAuthToken code ->
            ( model, exchangeToken googleExchangeTokenUrl (googleExchangeTokenBody code))

        OAuthTokenResponse response ->
            let
                token = Debug.log "oauth" response
            in
                update (SetActivePage Login) { model | oauthToken = token }

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
