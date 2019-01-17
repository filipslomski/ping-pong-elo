module Player exposing (Msg, State, emptyState, getPlayer, renderPlayer, update)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Http
import Json.Decode as D
import Palette exposing (..)
import Url.Builder as Url


type alias State =
    { matches : List Match
    , playerName : String
    , playerPosition : Int
    , playerRating : Int
    , playerRankImage : String
    }


type alias Match =
    { victorious : String
    , defeated : String
    }


type Msg
    = GotPlayer (Result Http.Error State)


emptyState : State
emptyState =
    { matches = []
    , playerName = ""
    , playerPosition = 0
    , playerRating = 0
    , playerRankImage = ""
    }


renderPlayer : State -> List (Element Msg)
renderPlayer st =
    let
        headerStyle =
            [ height (px 50)
            , Font.size 20
            , Font.bold
            , Font.color colorB1
            ]

        th title =
            el [ centerY, centerX ] <| text title

        td val =
          el [height (px 50), width fill] (el [ Font.color colorB2, Font.size 18, centerX ] (text val) )

    in
    [ row
        [ width (fill |> maximum 1100 |> minimum 800), centerX, spacing 10 ]
        [ el
            [ Font.color colorA2, Font.size 20, Font.bold ]
            (text <| "#" ++ String.fromInt st.playerPosition)
        , image [ height (px 20) ] { src = st.playerRankImage, description = "Rank" }
        , el
            [ Font.color colorA2, Font.size 20, Font.bold ]
            (text <| String.toUpper st.playerName)
        ]
    , table
        [ width (fill |> maximum 1100 |> minimum 800)
        , Background.color colorA4
        , padding 10
        , spacing 10
        , centerX
        , Border.color colorA4
        , Border.width 1
        , Border.solid
        , Border.roundEach { topLeft = 15, topRight = 15, bottomLeft = 0, bottomRight = 0 }
        , Border.shadow { offset = ( 0, 0 ), size = 1, blur = 15, color = rgba 0 0 0 0.25 }
        ]
        { data = st.matches
        , columns =
            [ { header = el headerStyle (th "Winner")
              , width = fill
              , view = td << .victorious
              }
            , { header = el headerStyle (th "Loser")
              , width = fill
              , view = td << .defeated
              }
            ]
        }
    ]


update : Msg -> State -> ( State, Cmd Msg )
update m st =
    case m of
        GotPlayer res ->
            case res of
                Ok r ->
                    ( r, Cmd.none )

                Err _ ->
                    ( st, Cmd.none )


getPlayer : String -> String -> Cmd Msg
getPlayer name gameUrl =
    Http.get
        { url = Url.absolute [ "get_player", gameUrl, name ] []
        , expect = Http.expectJson GotPlayer decodePlayer
        }


decodePlayer : D.Decoder State
decodePlayer =
    D.map5
        (\m n p r i ->
            { matches = m
            , playerName = n
            , playerPosition = p
            , playerRating = r
            , playerRankImage = i
            }
        )
        (D.field "matches" <| D.list decodeMatch)
        (D.field "name" D.string)
        (D.field "position" D.int)
        (D.field "rating" D.int)
        (D.field "rank_image" D.string)


decodeMatch : D.Decoder Match
decodeMatch =
    D.map2
        (\v d -> { victorious = v, defeated = d })
        (D.field "victorious" D.string)
        (D.field "defeated" D.string)
