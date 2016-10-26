module View exposing (view)

import Html exposing (Html, text, div, h1, p, a, br, button)
import Html.Attributes exposing (href)
import Model exposing (Model)
import Types exposing (Page(..))
import Update exposing (Msg, googleAuthUrl)


view : Model -> Html Msg
view model =
    let
        pageContent =
            case model.activePage of
                Login ->
                    [ a [ href (googleAuthUrl model) ] [ text "Login with Google" ] ]

                _ -> [ p [] [ text "Your Elm App is working!" ] ]
    in
        div []
            (
                [ h1 [] [ text model.pageTitle ] ]
                ++ pageContent ++
                [ br [] []
                , a [ href "/#" ] [ text "Home" ]
                , text " "
                , a [ href "/#login" ] [ text "Login" ]
                , text " "
                , a [ href "/#app/my-account" ] [ text "My Account" ]
                , text " "
                , a [ href "/#app/no-account" ] [ text "No Account" ]
                ]
            )
