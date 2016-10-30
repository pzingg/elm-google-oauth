module View exposing (view)

import Html exposing (Html, text, div, h1, p, a, br, button)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)

import Material
import Material.Button as Button
import Material.Card as Card exposing (Block)
import Material.Color as Color exposing (white)
import Material.Layout as Layout
import Material.Options as Options exposing (css)
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


csrfTokenForLogin : Model -> Maybe String
csrfTokenForLogin model =
    case model.activePage of
        Login ->
            case model.oauthToken of
                Success _ ->
                    Nothing

                _ ->
                    model.csrfToken
        _ ->
            Nothing


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


cardActions : Model -> List (Block Msg)
cardActions model =
    let
        maybeToken = csrfTokenForLogin model
    in
        case maybeToken of
            Just token ->
                [
                    Card.actions
                        [ Card.border ]
                        [ Button.render Mdl [ 1 ] model.mdl
                            [ Button.ripple
                            , Button.raised
                            , Button.onClick (LogIntoGoogle token)
                            -- , Button.link
                            -- , Options.attr <| href (googleAuthUrl token)
                            ]
                            [ text "Log in with Google" ]
                        ]
                ]

            Nothing ->
                []


{-| TODO See use of dynamic style in cards demo
-}
viewCard : Model -> String -> String -> Html Msg
viewCard model cardHeadText cardText =
    let blocks =
        [ Card.title
            [ css "background" "url('/static/media/pomegranate.fb8b833e.jpg') center / cover"
            , css "height" "256px"
            , css "padding" "0" -- Clear default padding to encompass scrim
            ]
            [ Card.head
                [ Color.text white
                , Options.scrim 0.75
                , css "padding" "16px" -- Restore default padding inside scrim
                , css "width" "100%"
                ]
                [ text cardHeadText ]
            ]
        , Card.text [] [ text cardText ]
        ] ++ (cardActions model)
    in
      Card.view
        [ css "width" "100%"
        , css "margin" "0"
        ]
        blocks


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


{-| TODO compiled = Styles.compile Styles.css
-}
viewBody : Model -> Html Msg
viewBody model =
    let
        cardHeadText = model.pageTitle
        cardText =
            case model.activePage of
                Login ->
                    case model.oauthToken of
                        Success token ->
                            "You are now logged in!"

                        _ ->
                            case model.csrfToken of
                                Just token ->
                                    "Ready to log in, just click the button."

                                _ ->
                                    "Not ready to log in, please refresh page!"

                MyAccount ->
                    case model.userInfo of
                        Success userInfo ->
                            "Welcome, " ++ userInfo.email

                        _ ->
                            "Ouch! I can't find your user information!"

                _ -> "Your Elm App is working!"
    in
        viewCard model cardHeadText cardText
