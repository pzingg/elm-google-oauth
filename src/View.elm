module View exposing (view)

import Html exposing (Html, text, div, h1, p, a, br, button)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)

import Material
import Material.Button as Button
import Material.Color as Color
import Material.Layout as Layout
import Material.Options as Options
import Material.Scheme
import RemoteData exposing (RemoteData(..))

import Model exposing (Model)
import Types exposing (Page(..))
import Update exposing (Msg(..), googleAuthUrl)


isAuthenticated : Model -> Bool
isAuthenticated model =
    case model.oauthToken of
        Success _ ->
            True

        _ ->
            False


view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.Teal Color.LightGreen <|
        Layout.render Mdl model.mdl
            [ Layout.fixedHeader ]
            { header = [ viewHeader model ]
            , drawer = []
            , tabs = ( [], [] )
            , main = [ viewBody model ]
            }


viewHeader : Model -> Html Msg
viewHeader model =
    let
        links =
            if isAuthenticated model
            then
                authenticatedLinks
            else
                topLevelLinks
    in
        Layout.row
            []
            [ Layout.title [] [ text "Google OAuth" ]
            , Layout.spacer
            , Layout.navigation [] (links model)
            ]


topLevelLinks : Model -> List (Html Msg)
topLevelLinks model =
    [ Layout.link
        [ Layout.href "/#" ]
        [ text "Home" ]
    , Layout.link
        [ Layout.href "/#login" ]
        [ text "Log In" ]
    ]


authenticatedLinks : Model -> List (Html Msg)
authenticatedLinks model =
    [ Layout.link
        [ Layout.href "/#" ]
        [ text "Home" ]
    , Layout.link
        [ Layout.onClick LogOut ]
        [ text "Log Out" ]
    , Layout.link
        [ Layout.href "/#app/my-account" ]
        [ text "My Account" ]
    , Layout.link
        [ Layout.href "/#app/no-account" ]
        [ text "No Account" ]
    ]


viewBody : Model -> Html Msg
viewBody model =
    let
        {-
        compiled =
            Styles.compile Styles.css
        -}
        pageContent =
            case model.activePage of
                Login ->
                    case model.oauthToken of
                        Success token ->
                            [ p [] [ text "You are now logged in!" ] ]

                        _ ->
                            case model.csrfToken of
                                Just token ->
                                    [
                                        Button.render Mdl [ 1 ] model.mdl
                                        [ Button.ripple
                                        , Button.raised
                                        , Button.onClick (LogIntoGoogle token)
                                        -- , Button.link
                                        -- , Options.attr <| href (googleAuthUrl token)
                                        ]
                                        [ text "Log in with Google" ]
                                    ]

                                _ ->
                                    [ p [] [ text "Please refresh page!" ] ]

                MyAccount ->
                    case model.userInfo of
                        Success userInfo ->
                            [ p [] [ text ("Welcome, " ++ userInfo.email) ] ]

                        _ ->
                            [ p [] [ text "Ouch! I can't find your user information!" ] ]


                _ -> [ p [] [ text "Your Elm App is working!" ] ]
    in
        div []
            (
                [ h1 [] [ text model.pageTitle ] ]
                ++ pageContent
            )
