module Update exposing (Msg(..), init, update)

import Debug
import Time exposing (Time)
import Task
import Types exposing (Page(..))
import Model exposing (..)
import Tokens exposing (makeToken)


type Msg
    = LogIn
    | LogOut
    | SetActivePage Page
    | SetCSRFToken Time


init : (Model, Cmd Msg)
init =
    emptyModel ! []


never : Never -> a
never n =
    never n


setCSRFToken : Cmd Msg
setCSRFToken =
    Task.perform (\_ -> Debug.crash "Time.now") SetCSRFToken Time.now


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetCSRFToken time ->
            { model | csrfToken = makeToken time } ! []

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
                Logout ->
                    { model | activePage = page, pageTitle = "Logout" } ! []

        _ ->
            model ! []
