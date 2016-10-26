module Model exposing (Model, emptyModel)

import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (Page(..), OAuthToken, UserInfo)


type alias Model =
    { activePage : Page
    , pageTitle : String
    , csrfToken : String
    , oauthToken : WebData OAuthToken
    , userInfo : WebData UserInfo
    }


emptyModel : Model
emptyModel =
    { activePage = Home
    , pageTitle = "Welcome!"
    , csrfToken = ""
    , oauthToken = NotAsked
    , userInfo = NotAsked
    }
