module App exposing (App, Game, Msg(..), initialApp, renderApp, updateApp)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav exposing (Key)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Leaderboard
import Palette exposing (..)
import Player
import Url exposing (Url)
import Url.Parser as Url exposing ((</>))


type alias App =
    { pageTitle : String
    , page : Page
    , urlKey : Key
    , games : List Game
    , activeGameUrl : String
    }


type alias Game =
    { name : String
    , url : String
    }


type Msg
    = LeaderboardMsg Leaderboard.Msg
    | PlayerMsg Player.Msg
    | UrlChangeAttempt UrlRequest
    | UrlChanged Url


type Page
    = Leaderboard Leaderboard.State
    | Player Player.State


type PageUrl
    = RatingsPage String
    | UserRatingsPage String String


initialApp : Key -> List Game -> App
initialApp key g =
    { pageTitle = "Elo"
    , page = Leaderboard Leaderboard.emptyState
    , urlKey = key
    , games = g
    , activeGameUrl = ""
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

        PlayerMsg pmsg ->
            let
                state =
                    case app.page of
                        Player s ->
                            s

                        _ ->
                            Player.emptyState

                ( st, cmd ) =
                    Player.update pmsg state
            in
            ( { app | page = Player st }, Cmd.map PlayerMsg cmd )

        UrlChangeAttempt req ->
            case req of
                Internal url ->
                    ( app
                    , Nav.pushUrl app.urlKey (Url.toString url)
                    )

                External url ->
                    ( app
                    , Nav.load url
                    )

        UrlChanged url ->
            case Url.parse pageUrlParser url of
                Just (RatingsPage gUrl) ->
                    let
                        game =
                            Maybe.withDefault { name = "", url = "" } <| List.head <| List.filter (\g -> g.url == gUrl) app.games
                    in
                    ( { app
                        | page = Leaderboard Leaderboard.emptyState
                        , activeGameUrl = gUrl
                        , pageTitle = game.name ++ " ratings"
                      }
                    , Cmd.map LeaderboardMsg <| Leaderboard.getRatings gUrl
                    )

                Just (UserRatingsPage gUrl name) ->
                    let
                        game =
                            Maybe.withDefault { name = "", url = "" } <| List.head <| List.filter (\g -> g.url == gUrl) app.games
                    in
                    ( { app
                        | activeGameUrl = gUrl
                        , page = Player Player.emptyState
                        , pageTitle = (Maybe.withDefault "" <| Url.percentDecode name) ++ " ratings in " ++ game.name
                      }
                    , Cmd.map PlayerMsg <| Player.getPlayer name gUrl
                    )

                Nothing ->
                    let
                        game =
                            Maybe.withDefault { name = "", url = "" } <| List.head app.games
                    in
                    ( { app | pageTitle = game.name ++ " ratings", activeGameUrl = game.url }
                    , Nav.replaceUrl app.urlKey <| "/" ++ game.url ++ "/ratings"
                    )


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

                    Player st ->
                        List.map (Element.map PlayerMsg) <| Player.renderPlayer st
            ]


renderLogo : Element Msg
renderLogo =
    el [ height fill, Font.color colorA1, Font.size 48, Font.bold ] (el [ centerY ] <| text "Elo")


renderMenu : App -> Element Msg
renderMenu app =
    row
        [ alignLeft, spacing 15, paddingEach { top = 15, left = 0, right = 0, bottom = 0 } ]
        (List.map (\g -> renderMenuItem g (g.url == app.activeGameUrl)) <| List.sortBy .name app.games)


renderMenuItem : Game -> Bool -> Element Msg
renderMenuItem g active =
    link
        [ Font.color <|
            if active then
                colorC2

            else
                colorA2
        , if active then
            Font.bold

          else
            Font.regular
        ]
        { url = "/" ++ g.url ++ "/ratings", label = text g.name }


pageUrlParser : Url.Parser (PageUrl -> a) a
pageUrlParser =
    Url.oneOf
        [ Url.map UserRatingsPage (Url.string </> Url.s "ratings" </> Url.string)
        , Url.map RatingsPage (Url.string </> Url.s "ratings")
        ]
