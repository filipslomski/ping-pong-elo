module Main exposing (main)

import Browser
import App exposing (..)

main : Program (List Game) App Msg
main =
  Browser.application
    { init = \games url key -> updateApp (UrlChanged url) (initialApp key games)
    , view = renderApp
    , update = updateApp
    , subscriptions = always Sub.none
    , onUrlRequest = UrlChangeAttempt
    , onUrlChange = UrlChanged
    }
