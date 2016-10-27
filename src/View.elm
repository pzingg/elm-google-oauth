module View exposing (view)

import Html exposing (Html, text, div, h1, p, a, br, button)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)

import RemoteData exposing (RemoteData(..))

import Model exposing (Model)
import Types exposing (Page(..))
import Update exposing (Msg(..), googleAuthUrl)


view : Model -> Html Msg
view model =
    let
        pageContent =
            case model.activePage of
                Login ->
                    case model.oauthToken of
                        Success token ->
                            [ p [] [ text "You are now logged in!" ] ]

                        _ ->
                            case model.csrfToken of
                                Just token ->
                                    [ a [ href (googleAuthUrl token) ] [ text "Log in with Google" ] ]

                                _ ->
                                    [ p [] [ text "Please refresh page!" ] ]

                MyAccount ->
                    case model.userInfo of
                        Success userInfo ->
                            [ p [] [ text ("Welcome, " ++ userInfo.email) ] ]

                        _ ->
                            [ p [] [ text "Ouch! I can't find your user information!" ] ]


                _ -> [ p [] [ text "Your Elm App is working!" ] ]

        navContent =
            case model.oauthToken of
                Success token ->
                    [ a [ href "/#" ] [ text "Home" ]
                    , text " "
                    , a [ onClick LogOut ] [ text "Log Out" ]
                    , text " "
                    , a [ href "/#app/my-account" ] [ text "My Account" ]
                    , text " "
                    , a [ href "/#app/no-account" ] [ text "No Account" ]
                    ]

                _ ->
                    [ a [ href "/#" ] [ text "Home" ]
                    , text " "
                    , a [ href "/#login" ] [ text "Log In" ]
                    ]
    in
        div []
            (
                [ h1 [] [ text model.pageTitle ] ]
                ++ pageContent ++
                [ br [] [] ]
                ++ navContent
            )
