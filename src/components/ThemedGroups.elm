module Components.ThemedGroups exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Config exposing (Msg(..), Theme)
import Components.ThemedGroup exposing (themedGroup)


themedGroups : Maybe (List ( Theme, List String )) -> Html Msg
themedGroups groups =
    case groups of
        Just groups_ ->
            div [] (List.map themedGroup groups_)

        Nothing ->
            text ""
