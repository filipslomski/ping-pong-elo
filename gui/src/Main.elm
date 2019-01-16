module Main exposing (main)

import Browser
import App exposing (..)

main : Program () App Msg
main =
  Browser.document
    { init = always ( initialApp, Cmd.none )
    , view = renderApp
    , update = updateApp
    , subscriptions = always Sub.none
    }
