module Model exposing (Model, emptyModel)

import Types exposing (Page(..))


type alias Model =
    { activePage : Page
    , pageTitle : String
    , csrfToken : String
    }


emptyModel : Model
emptyModel =
    { activePage = Home
    , pageTitle = "Welcome!"
    , csrfToken = ""
    }
