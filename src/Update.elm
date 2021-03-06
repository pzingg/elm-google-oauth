module Update exposing (Msg(..), init, update, googleAuthUrl)

import Debug
import Dict exposing (Dict)
import Json.Decode as JD
import String
import Time exposing (Time)
import Task exposing (Task)

import Erl
import Http exposing (Error(..))
import LocalStorage
import Material
import RemoteData exposing (WebData, RemoteData(..))

import ClientSecrets exposing (redirectURI, clientID, clientSecret, googleDomain)
import Decoders exposing (decodeOAuthToken, decodeUserInfo)
import Google
import Model exposing (..)
import Ports exposing (externalHref)
import Tokens exposing (newToken)
import Types exposing (Page(..),  OAuthToken, UserInfo)


-- MESSAGES


type Msg
    = SetActivePage Page
    | StoreCSRFToken
    | ClearCSRFToken
    | SetCSRFToken (Maybe String)
    | ExchangeOAuthToken (Maybe String) (Maybe String)
    | OAuthTokenResponse (WebData OAuthToken)
    | UserInfoResponse (WebData UserInfo)
    | LogIntoGoogle String
    | LogOut
    | StorageFailure LocalStorage.Error
    | Mdl (Material.Msg Msg)
    | NoOp String


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


-- TASKS


andThen =
    (flip Task.andThen)


fetchCSRFToken : Task LocalStorage.Error (Maybe String)
fetchCSRFToken =
    LocalStorage.get "csrfToken"


clearCSRFToken : Task LocalStorage.Error String
clearCSRFToken =
    LocalStorage.remove "csrfToken"
        |> andThen (\() -> Task.succeed "csrfToken cleared")


storeCSRFToken : Task LocalStorage.Error (Maybe String)
storeCSRFToken =
    Time.now
        |> andThen (\time -> Task.succeed (newToken time))
        |> andThen (\token -> LocalStorage.set "csrfToken" token)
        |> andThen (\() -> fetchCSRFToken)


checkOAuthResponse : Maybe String -> Maybe String -> Maybe String -> Task Http.Error String
checkOAuthResponse localToken returnedToken maybeCode =
    case (localToken, returnedToken, maybeCode) of
        (Just tlocal, Just tauth, Just code) ->
            if tlocal == tauth
            then
                Task.succeed code
            else
                Task.fail (UnexpectedPayload "Possible CSR forgery")

        (_, _, Nothing) ->
            Task.fail (UnexpectedPayload "No code returned from auth")

        (_, Nothing, _) ->
            Task.fail (UnexpectedPayload "No CSRF token returned from auth")

        (Nothing, _, _) ->
            Task.fail (UnexpectedPayload "No CSRF token in storage")


-- COMMANDS


exchangeTokenCmd : Maybe String -> Maybe String -> Cmd Msg
exchangeTokenCmd returnedToken maybeCode =
    Task.onError fetchCSRFToken (\_ -> Task.fail (UnexpectedPayload "Local storage not available"))
        |> andThen (\localToken ->
            checkOAuthResponse localToken returnedToken maybeCode)
        |> andThen (\code ->
            postFormUrlEncoded decodeOAuthToken Google.tokenEndpoint (googleExchangeTokenBody code))
        |> RemoteData.asCmd
        |> Cmd.map OAuthTokenResponse


getUserInfoCmd : Model -> Cmd Msg
getUserInfoCmd model =
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
                    { model | activePage = page, pageTitle = "Login" } ! []
                PageNotFound ->
                    { model | activePage = page, pageTitle = "Not Found!" } ! []
                AccessDenied ->
                    { model | activePage = page, pageTitle = "Access Denied!" } ! []
                MyAccount ->
                    { model | activePage = page, pageTitle = "My Account" } ! []

        StoreCSRFToken ->
            ( model, (Task.perform StorageFailure SetCSRFToken storeCSRFToken) )

        ClearCSRFToken ->
            ( { model | csrfToken = Nothing }, (Task.perform StorageFailure NoOp clearCSRFToken) )

        SetCSRFToken maybeToken ->
            { model | csrfToken = maybeToken } ! []

        ExchangeOAuthToken returnedToken maybeCode ->
            ( { model | csrfToken = Nothing }, (exchangeTokenCmd returnedToken maybeCode) )

        OAuthTokenResponse oauthToken ->
            case oauthToken of
                Success _ ->
                    let
                        newModel =
                            { model
                            | oauthToken = oauthToken
                            , activePage = Login
                            , pageTitle = "Login"
                            }
                    in
                        (newModel, getUserInfoCmd newModel)

                Failure e ->
                    let
                        _ = Debug.log "oauth error" e
                    in
                        model ! []

                _ ->
                    model ! []

        UserInfoResponse userInfo ->
            case userInfo of
                Success _ ->
                    { model | userInfo = userInfo } ! []

                Failure e ->
                    let
                        _ = Debug.log "userinfo error" e
                    in
                        model ! []

                _ ->
                    model ! []

        LogIntoGoogle token ->
            model ! [ externalHref (googleAuthUrl token) ]

        LogOut ->
            { model
            | oauthToken = NotAsked
            , userInfo = NotAsked
            , activePage = Home
            , pageTitle = "Welcome!"
            } ! []

        StorageFailure error ->
            let
                e = Debug.log "StorageFailure" error
            in
                model ! []

        Mdl materialMsg ->
            Material.update materialMsg model

        NoOp msg ->
            let
                m = Debug.log "NoOp" msg
            in
                model ! []
