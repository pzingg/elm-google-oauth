module Update exposing (Msg(..), init, update, googleAuthUrl)

import Debug
import String
import Dict
import Time exposing (Time)
import Task exposing (Task)
import Http
import Json.Decode as JD
import Erl
import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (Page(..), OAuthToken, UserInfo)
import Decoders exposing (decodeOAuthToken, decodeUserInfo)
import Model exposing (..)
import Tokens exposing (makeToken)
import ClientSecrets exposing (redirectURI, clientID, clientSecret, googleDomain)
import Google


-- MESSAGES


type Msg
    = LogOut
    | SetActivePage Page
    | SetCSRFToken Time
    | ExchangeOAuthToken String
    | OAuthTokenResponse (WebData OAuthToken)
    | UserInfoResponse (WebData UserInfo)


-- HELPERS


never : Never -> a
never n =
    never n


googleAuthQuery : Model -> List (String, String)
googleAuthQuery model =
    [ ( "client_id", clientID )
    , ( "response_type", "code" )
    , ( "scope", "openid email profile" )
    , ( "redirect_uri", redirectURI )
    , ( "state", "csrf " ++ model.csrfToken )
    , ( "hd", googleDomain )
    ]


googleAuthUrl : Model -> String
googleAuthUrl model =
    let
        erl = Erl.parse Google.authorizationEndpoint
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


getUserInfo : Model -> Cmd Msg
getUserInfo model =
    case model.oauthToken of
        Success token ->
            let
                url = Google.userinfoEndpoint ++
                    "?alt=json&access_token=" ++ token.accessToken
            in
                Http.get decodeUserInfo url
                    |> RemoteData.asCmd
                    |> Cmd.map UserInfoResponse

        _ ->
            Cmd.none


-- INIT


init : (Model, Cmd Msg)
init =
    emptyModel ! []


-- UPDATE


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LogOut ->
            let
                ( newModel, _ ) = update (SetActivePage Home) { model | oauthToken = NotAsked, userInfo = NotAsked }
            in
                newModel ! []

        SetCSRFToken time ->
            { model | csrfToken = makeToken time } ! []

        ExchangeOAuthToken code ->
            ( model, exchangeToken Google.tokenEndpoint (googleExchangeTokenBody code))

        OAuthTokenResponse response ->
            let
                token = Debug.log "oauth" response
                ( newModel, _ ) = update (SetActivePage Login) { model | oauthToken = token }
            in
                ( newModel, getUserInfo newModel )

        UserInfoResponse response ->
            let
                userInfo = Debug.log "userinfo" response
            in
                { model | userInfo = userInfo } ! []

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
