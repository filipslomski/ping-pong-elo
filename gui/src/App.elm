module App exposing (App, Msg(..), initialApp, renderApp, updateApp)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Leaderboard
import Palette exposing (..)


type alias App =
    { pageTitle : String
    , page : Page
    }


type Msg
    = LeaderboardMsg Leaderboard.Msg


type Page
    = Leaderboard Leaderboard.State
    | Player


initialApp : App
initialApp =
    { pageTitle = "Elo"
    , page = Leaderboard Leaderboard.emptyState
    }


renderApp : App -> Browser.Document Msg
renderApp app =
    { title = app.pageTitle
    , body = [ renderLayout app ]
    }


updateApp : Msg -> App -> ( App, Cmd Msg )
updateApp m app =
    case m of
        LeaderboardMsg pmsg ->
            let
                state =
                    case app.page of
                        Leaderboard s ->
                            s

                        _ ->
                            Leaderboard.emptyState

                ( st, cmd ) =
                    Leaderboard.update pmsg state
            in
            ( { app | page = Leaderboard st }, Cmd.map LeaderboardMsg cmd )


renderLayout : App -> Html Msg
renderLayout app =
    layout
        [ Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=Montserrat"
                , name = "Montserrat"
                }
            , Font.sansSerif
            ]
        , Background.color colorA3
        ]
    <|
        column
            [ width fill, height fill ]
            [ row [ height (px 100), width fill, padding 10, spacing 10 ] [ renderLogo, renderMenu app ]
            , column
                [ height fill, width fill, padding 10, spacing 20 ]
              <|
                case app.page of
                    Leaderboard st ->
                        List.map (Element.map LeaderboardMsg) <| Leaderboard.renderLeaderboard st

                    Player ->
                        []
            ]


renderLogo : Element Msg
renderLogo =
    el [ height fill, Font.color colorA1, Font.size 48, Font.bold ] (el [ centerY ] <| text "Elo")


renderMenu : App -> Element Msg
renderMenu app =
    row
        [ alignLeft, spacing 15, paddingEach { top = 15, left = 0, right = 0, bottom = 0 } ]
        [ link [ Font.color colorA2 ] { url = "#", label = text "Ping pong" }
        , link [ Font.color colorA2 ] { url = "#", label = text "FIFA" }
        ]
