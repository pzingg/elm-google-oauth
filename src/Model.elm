module Model exposing (Model, emptyModel)

import Material
import RemoteData exposing (WebData, RemoteData(..))

import Types exposing (Page(..), OAuthToken, UserInfo)


type alias Model =
    { activePage : Page
    , pageTitle : String
    , csrfToken : Maybe String
    , oauthToken : WebData OAuthToken
    , userInfo : WebData UserInfo
    , mdl : Material.Model
    }


emptyModel : Model
emptyModel =
    { activePage = Home
    , pageTitle = "Welcome!"
    , csrfToken = Nothing
    , oauthToken = NotAsked
    , userInfo = NotAsked
    , mdl = Material.model
    }
