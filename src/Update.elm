module Update exposing (Msg(..), init, update)

import Types exposing (Page(..))
import Model exposing (..)


type Msg
    = LogIn
    | LogOut
    | SetActivePage Page


init : (Model, Cmd Msg)
init =
    emptyModel ! []


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetActivePage page ->
            let
                newModel =
                    case page of
                        Home ->
                            { model | activePage = page, pageTitle = "Welcome!" }
                        Login ->
                            { model | activePage = page, pageTitle = "Login" }
                        PageNotFound ->
                            { model | activePage = page, pageTitle = "Not Found!" }
                        AccessDenied ->
                            { model | activePage = page, pageTitle = "Access Denied!" }
                        MyAccount ->
                            { model | activePage = page, pageTitle = "My Account" }
                        Logout ->
                            { model | activePage = page, pageTitle = "Logout" }
            in
                newModel ! []

        _ ->
            model ! []
