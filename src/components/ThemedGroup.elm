module Components.ThemedGroup exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Config exposing (Msg(..), Theme)
import Components.ParticipantsList exposing (simpleParticipantsList)


themedGroup : ( Theme, List String ) -> Html Msg
themedGroup group =
    div []
        [ h4 [] [ text <| Tuple.first <| Tuple.first group ]
        , p [ class "theme-description" ] [ text <| Tuple.second <| Tuple.first group ]
        , simpleParticipantsList (Tuple.second group)
        ]
