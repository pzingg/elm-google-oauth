module Model exposing (Model, emptyModel)

import Types exposing (Page(..))


type alias Model =
    { activePage : Page
    , pageTitle : String
    }


emptyModel : Model
emptyModel =
    { activePage = Home
    , pageTitle = "Welcome!"
    }
