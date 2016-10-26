module Model exposing (Model, emptyModel)

import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (Page(..), OAuthToken)


type alias Model =
    { activePage : Page
    , pageTitle : String
    , csrfToken : String
    , oauthToken : WebData OAuthToken
    }


emptyModel : Model
emptyModel =
    { activePage = Home
    , pageTitle = "Welcome!"
    , csrfToken = ""
    , oauthToken = NotAsked
    }
