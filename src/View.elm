module View exposing (view)

import Html exposing (Html, text, div, h1, p, a)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Types exposing (Page(..))
import Update exposing (Msg(..))


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text model.pageTitle ]
        , p [] [ text "Your Elm App is working!" ]
        , a [ href "/#" ] [ text "Home" ]
        , text " "
        , a [ href "/#login" ] [ text "Login" ]
        , text " "
        , a [ href "/#app/my-account" ] [ text "My Account" ]
        , text " "
        , a [ href "/#app/no-account" ] [ text "No Account" ]
        ]
