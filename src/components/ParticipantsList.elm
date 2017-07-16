module Components.ParticipantsList
    exposing
        ( simpleParticipantsList
        , removableParticipantsListWithTitle
        , participantsList
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import String.Extra exposing (pluralize)
import Config exposing (Msg(..))
import Components.ParticipantsListItem exposing (participantsListItem)


simpleParticipantsList : List String -> Html Msg
simpleParticipantsList participants =
    participantsList False False participants


removableParticipantsListWithTitle : List String -> Html Msg
removableParticipantsListWithTitle participants =
    participantsList True True participants


participantsList : Bool -> Bool -> List String -> Html Msg
participantsList withTitle canRemoveItems participants =
    if withTitle then
        div []
            [ h2 [] [ text <| String.Extra.pluralize " participant" " participants" (List.length participants) ]
            , renderList canRemoveItems participants
            ]
    else
        renderList canRemoveItems participants


renderList : Bool -> List String -> Html Msg
renderList canRemoveItems participants =
    ul [ class "list-group" ] (List.map (\item -> participantsListItem canRemoveItems item) participants)
