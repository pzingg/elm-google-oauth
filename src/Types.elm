module Types exposing (Page(..), OAuthToken)

import Dict exposing (Dict)
import Time exposing (Time)

type Page
    = Home
    | Login
    | PageNotFound
    | AccessDenied
    | MyAccount
    | Logout


type alias OAuthToken =
    { accessToken : String
    , idToken : String
    , expiresInSeconds : Int
    , tokenType : String
    , refreshToken : Maybe String
    }
