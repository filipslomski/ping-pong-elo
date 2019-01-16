module Leaderboard exposing (Msg, Rating, State, emptyState, renderLeaderboard, update)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Palette exposing (..)


type alias State =
    { ratings : List Rating
    , sortBy : SortBy
    , sortDir : SortDir
    , filter : String
    }


type Msg
    = Sort SortBy SortDir
    | Filter String


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


type SortDir
    = Asc
    | Desc


emptyState : State
emptyState =
    { ratings =
        [ { position = 1, name = "Test player", rating = 1000, matches = 0, winStreak = 0, highestRating = 1000, rankImage = "", victories = 0 }
        , { position = 2, name = "Second player", rating = 980, matches = 1, winStreak = 0, highestRating = 1000, rankImage = "", victories = 0 }
        ]
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
      [ width (fill |> maximum 1100 |> minimum 800), focused [ ], centerX, Font.color colorA1, Background.color colorA4, Border.color colorA3 ]
      { onChange = Filter
      , text = st.filter
      , placeholder = Just <| Input.placeholder [ Font.color colorA3 ] <| el [] (text "Enter player name")
      , label = Input.labelLeft [ Font.color colorA2, padding 10 ] <| el [] (text "Search player")
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
        { data = sortByField st.sortBy st.sortDir <| List.filter (String.contains st.filter << .name) st.ratings
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
            , { header = el (headerStyle SMatches) (thRight "Matches")
              , width = fill
              , view = renderMatches
              }
            , { header = el (headerStyle SWinStreak) (thRight "Win streak")
              , width = fill
              , view = renderWinStreak
              }
            , { header = el (headerStyle SHighestRating) (thRight "Highest")
              , width = fill
              , view = renderHighest
              }
            , { header = el (headerStyle SVictories) (thRight "Victories")
              , width = fill
              , view = renderVictories
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


renderPosition : Rating -> Element Msg
renderPosition r =
    numCol r.position


renderPlayer : Rating -> Element Msg
renderPlayer r =
    el ratingColStyle <| el [ centerY, alignLeft ] (text r.name)


renderRating : Rating -> Element Msg
renderRating r =
    numCol r.rating


renderMatches : Rating -> Element Msg
renderMatches r =
    numCol r.matches


renderWinStreak : Rating -> Element Msg
renderWinStreak r =
    numCol r.winStreak


renderHighest : Rating -> Element Msg
renderHighest r =
    numCol r.highestRating


renderVictories : Rating -> Element Msg
renderVictories r =
    numCol r.victories


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
