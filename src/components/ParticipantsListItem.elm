module Components.ParticipantsListItem exposing (participantsListItem)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode exposing (string)
import List.Extra exposing (remove)
import Config exposing (Msg(..))


participantsListItem : Bool -> String -> Html Msg
participantsListItem canRemove participant =
    li [ class "list-group-item" ]
        ([ span []
            [ text participant ]
         ]
            ++ (if canRemove then
                    [ renderRemoveBtn participant ]
                else
                    []
               )
        )


renderRemoveBtn : String -> Html Msg
renderRemoveBtn participant =
    span
        [ class "participants-list-item-remove"
        , property "innerHTML" (Json.Encode.string "&times;")
        , onClick (RemoveParticipant participant)
        ]
        []
