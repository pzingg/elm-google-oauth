module Types exposing (Page(..), AuthError(..), OAuthToken, UserInfo)

import Dict exposing (Dict)
import Time exposing (Time)

type Page
    = Home
    | Login
    | PageNotFound
    | AccessDenied
    | MyAccount


type AuthError
    = CSRForgery
    | CodeMissing
    | CSRFMissing


type alias OAuthToken =
    { accessToken : String
    , idToken : String
    , expiresInSeconds : Int
    , tokenType : String
    , refreshToken : Maybe String
    }


type alias UserInfo =
    { name : Maybe String
    , givenName : Maybe String
    , familyName : Maybe String
    , email : String
    }
