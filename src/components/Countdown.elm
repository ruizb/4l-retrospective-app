module Components.Countdown exposing (countdown)

import Html exposing (..)
import Html.Attributes exposing (..)
import Config exposing (Msg(..))


countdown : Int -> Html Msg
countdown count =
    p [ class "countdown" ] [ text <| renderCountdown count ]


renderCountdown : Int -> String
renderCountdown count =
    (zeroPadNumber <| count // 60) ++ ":" ++ (zeroPadNumber <| count % 60)


zeroPadNumber : Int -> String
zeroPadNumber n =
    toString n |> String.padLeft 2 '0'
