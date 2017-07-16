module Config exposing (..)


type Msg
    = GetParticipants (List String)
    | StartItemsCreation
    | StartCreationTick
    | StartItemsGrouping
    | StartGroupingTick
    | GenerateGroups
    | ShuffledThemes (List Theme)
    | ShuffledGroups (List String)
    | RemoveParticipant String


type alias Theme =
    ( String, String )


type alias ThemedGroups =
    List ( Theme, List String )


type alias Model =
    { participants : List String
    , themedGroups : Maybe ThemedGroups
    , themes : List Theme
    , itemsCreationCountdown : Int
    , itemsGroupingCountdown : Int
    }
