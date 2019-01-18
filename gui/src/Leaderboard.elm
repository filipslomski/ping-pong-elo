module Leaderboard exposing (Msg, Rating, State, emptyState, getRatings, renderLeaderboard, update)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Http
import Json.Decode as D
import Palette exposing (..)
import String exposing (toLower)
import Url.Builder as Url


type alias State =
    { ratings : List Rating
    , sortBy : SortBy
    , sortDir : SortDir
    , filter : String
    }


type Msg
    = Sort SortBy SortDir
    | Filter String
    | GotRatings (Result Http.Error (List Rating))


type alias Rating =
    { name : String
    , rating : Int
    , matches : Int
    , winStreak : Int
    , highestRating : Int
    , rankImage : String
    , victories : Int
    , position : Int
    }


type SortBy
    = SPosition
    | SName
    | SRating
    | SMatches
    | SWinStreak
    | SHighestRating
    | SVictories
    | SWinRatio


type SortDir
    = Asc
    | Desc


emptyState : State
emptyState =
    { ratings = []
    , sortBy = SPosition
    , sortDir = Asc
    , filter = ""
    }


reverseSort : SortDir -> SortDir
reverseSort d =
    if d == Asc then
        Desc

    else
        Asc


renderLeaderboard : State -> List (Element Msg)
renderLeaderboard st =
    let
        headerStyle sfield =
            [ Events.onClick <|
                Sort sfield <|
                    if st.sortBy == sfield then
                        reverseSort st.sortDir

                    else
                        Asc
            , pointer
            , height (px 50)
            , Font.size 20
            , Font.bold
            , Font.color colorB1
            ]
                ++ (if st.sortBy == sfield then
                        [ Font.underline ]

                    else
                        []
                   )

        th title =
            el [ centerY ] <| text title

        thRight title =
            el [ centerY, alignRight ] <| text title
    in
    [ Input.search
        [ width (fill |> maximum 1100 |> minimum 800), focused [], centerX, Font.color colorA1, Background.color colorA4, Border.color colorA3 ]
        { onChange = Filter
        , text = st.filter
        , placeholder = Just <| Input.placeholder [ Font.color colorA3 ] <| el [] (text "Enter player name")
        , label = Input.labelLeft [ Font.color colorA2, padding 10 ] <| el [ centerY ] (text "Search player")
        }
    , table
        [ width (fill |> maximum 1100 |> minimum 800)
        , Background.color colorC4
        , padding 10
        , spacing 10
        , centerX
        , Border.color colorC4
        , Border.width 1
        , Border.solid
        , Border.roundEach { topLeft = 15, topRight = 15, bottomLeft = 0, bottomRight = 0 }
        , Border.shadow { offset = ( 0, 0 ), size = 1, blur = 15, color = rgba 0 0 0 0.25 }
        ]
        { data = sortByField st.sortBy st.sortDir <| List.filter (String.contains (toLower st.filter) << toLower << .name) st.ratings
        , columns =
            [ { header = el (headerStyle SPosition) (thRight "#")
              , width = px 25
              , view = renderPosition
              }
            , { header = el (headerStyle SName) (th "Player")
              , width = fill
              , view = renderPlayer
              }
            , { header = el (headerStyle SRating) (thRight "Rating")
              , width = fill
              , view = renderRating
              }
            , { header = el (headerStyle SWinStreak) (thRight "Win streak")
              , width = fill
              , view = renderWinStreak
              }
            , { header = el (headerStyle SHighestRating) (thRight "Highest")
              , width = fill
              , view = renderHighest
              }
            , { header = el (headerStyle SWinRatio) (thRight "Win ratio")
              , width = fill
              , view = renderWinRatio
              }
            ]
        }
    ]


ratingColStyle : List (Attribute Msg)
ratingColStyle =
    [ height (px 50), Font.color colorB1, Font.size 18 ]


numCol : Int -> Element Msg
numCol v =
    el ratingColStyle <| el [ centerY, alignRight ] (text <| String.fromInt v)


floatCol : Float -> Element Msg
floatCol v =
    el ratingColStyle <| el [ centerY, alignRight ] (text <| String.fromFloat v)


renderPosition : Rating -> Element Msg
renderPosition r =
    numCol r.position


renderPlayer : Rating -> Element Msg
renderPlayer r =
    row
        [ spacing 10 ]
        [ image [ height (px 18) ] { src = r.rankImage, description = "Rank" }
        , link
            ratingColStyle
            { url = Url.relative [ "ratings", r.name ] [], label = el [ centerY, alignLeft ] (text r.name) }
        ]


renderRating : Rating -> Element Msg
renderRating r =
    numCol r.rating


renderWinStreak : Rating -> Element Msg
renderWinStreak r =
    numCol r.winStreak


renderHighest : Rating -> Element Msg
renderHighest r =
    numCol r.highestRating


round2 : Float -> Float
round2 n =
    toFloat (round (n * 100)) / 100


renderWinRatio : Rating -> Element Msg
renderWinRatio r =
    floatCol <| round2 (toFloat r.victories / toFloat (max 1 r.matches))


sortByField : SortBy -> SortDir -> List Rating -> List Rating
sortByField field dir =
    let
        cmpField r1 r2 =
            case field of
                SPosition ->
                    compare r1.position r2.position

                SName ->
                    compare r1.name r2.name

                SRating ->
                    compare r1.rating r2.rating

                SMatches ->
                    compare r1.matches r2.matches

                SWinStreak ->
                    compare r1.winStreak r2.winStreak

                SHighestRating ->
                    compare r1.highestRating r2.highestRating

                SVictories ->
                    compare r1.victories r2.victories

                SWinRatio ->
                    compare
                        (toFloat r1.victories / toFloat (max 1 r1.matches))
                        (toFloat r2.victories / toFloat (max 1 r2.matches))
    in
    List.sortWith
        (\r1 r2 ->
            case cmpField r1 r2 of
                LT ->
                    if dir == Asc then
                        LT

                    else
                        GT

                EQ ->
                    EQ

                GT ->
                    if dir == Asc then
                        GT

                    else
                        LT
        )


update : Msg -> State -> ( State, Cmd Msg )
update m st =
    case m of
        Sort field dir ->
            ( { st
                | sortBy = field
                , sortDir = dir
              }
            , Cmd.none
            )

        Filter val ->
            ( { st | filter = val }
            , Cmd.none
            )

        GotRatings res ->
            case res of
                Ok r ->
                    ( { st | ratings = List.indexedMap (\idx rr -> { rr | position = idx + 1 }) r }
                    , Cmd.none
                    )

                Err _ ->
                    ( st, Cmd.none )


getRatings : String -> Cmd Msg
getRatings gameUrl =
    Http.get
        { url = Url.absolute [ "get_ratings", gameUrl ] []
        , expect = Http.expectJson GotRatings (D.list decodeRating)
        }


decodeRating : D.Decoder Rating
decodeRating =
    D.map7
        (\n h m i r v w ->
            { name = n
            , rating = r
            , matches = m
            , winStreak = w
            , highestRating = h
            , rankImage = i
            , victories = v
            , position = 0
            }
        )
        (D.field "name" D.string)
        (D.field "highest_rating" D.int)
        (D.field "matches" D.int)
        (D.field "rank_image" D.string)
        (D.field "rating" D.int)
        (D.field "victories" D.int)
        (D.field "win_streak" D.int)
