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
    = SetActivePage Page
    | SetCSRFToken Time
    | ExchangeOAuthToken String
    | OAuthTokenResponse (WebData OAuthToken)
    | UserInfoResponse (WebData UserInfo)
    | LogOut


-- HELPERS


never : Never -> a
never n =
    never n


googleAuthQuery : String -> List (String, String)
googleAuthQuery token =
    [ ( "client_id", clientID )
    , ( "response_type", "code" )
    , ( "scope", "openid email profile" )
    , ( "redirect_uri", redirectURI )
    , ( "state", "csrf-" ++ token )
    , ( "hd", googleDomain )
    ]


{-| Google's token exchange endpoint apparently does not accept JSON data,
    so we create the www-form-urlencoded body here.
-}
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


googleAuthUrl : String -> String
googleAuthUrl token =
    let
        erl = Erl.parse Google.authorizationEndpoint
    in
        Erl.toString { erl | query = Dict.fromList (googleAuthQuery token) }


userInfoUrl : String ->  String
userInfoUrl accessToken =
    Google.userinfoEndpoint ++
        "?alt=json&access_token=" ++ accessToken


{-| Google's token exchange endpoint apparently does not accept JSON data,
    so we have to change the Content-Type header when we POST.
-}
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


exchangeToken : String -> Cmd Msg
exchangeToken code =
    postFormUrlEncoded decodeOAuthToken Google.tokenEndpoint (googleExchangeTokenBody code)
        |> RemoteData.asCmd
        |> Cmd.map OAuthTokenResponse


getUserInfo : Model -> Cmd Msg
getUserInfo model =
    case model.oauthToken of
        Success token ->
            Http.get decodeUserInfo (userInfoUrl token.accessToken)
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

        SetCSRFToken time ->
            { model | csrfToken = Just (makeToken time) } ! []

        ExchangeOAuthToken code ->
            ( model, exchangeToken code )

        OAuthTokenResponse oauthToken ->
            case oauthToken of
                Success _ ->
                    let
                        ( newModel, _ ) = update (SetActivePage Login) { model | oauthToken = oauthToken }
                    in
                        ( newModel, getUserInfo newModel )

                _ ->
                    { model | oauthToken = oauthToken } ! []

        UserInfoResponse userInfo ->
            { model | userInfo = userInfo } ! []

        LogOut ->
            let
                ( newModel, _ ) = update (SetActivePage Home) { model | oauthToken = NotAsked, userInfo = NotAsked }
            in
                newModel ! []
