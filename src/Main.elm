port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Time exposing (now, second)
import Platform.Cmd exposing (none)
import Task exposing (perform)
import Process exposing (sleep)
import Random exposing (generate)
import Random.List exposing (shuffle)
import List.Extra exposing (greedyGroupsOf)
import Components.ThemedGroups exposing (themedGroups)
import Components.ParticipantsList exposing (removableParticipantsListWithTitle)
import Components.Countdown exposing (countdown)
import Config exposing (Msg(..), Theme, ThemedGroups, Model)


initialThemes : List Theme
initialThemes =
    [ ( "Liked", "What did you like?" )
    , ( "Lacked of", "What was missing to work better? what could be improved?" )
    , ( "Learned", "What did you learn?" )
    , ( "Longed for", "What would you like for the next iteration?" )
    ]


initialItemsCreationCountdown : Int
initialItemsCreationCountdown =
    5 * 60


initialItemsGroupingCountdown : Int
initialItemsGroupingCountdown =
    15 * 60



{-
   Given a number of groups (n) and a total number of elements (total),
   generate a list of n elements: used to generate n groups which their
   number of elements match the elements of this generated list.
   Example:
       (getGroupsOfVarying 2 5) gives [2, 2, 1]
       Given [a, b, c, d, e], List.Extra.groupsOfVarying will create
       [[a, b], [c, d], [e]]
-}


main =
    Html.program
        { init = ( Model [] Nothing initialThemes initialItemsCreationCountdown initialItemsGroupingCountdown, requestParticipants () )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


port requestParticipants : () -> Cmd msg


port getParticipants : (List String -> msg) -> Sub msg


getGroupsOfVarying : Int -> Int -> List Int
getGroupsOfVarying n total =
    if n == 0 then
        []
    else
        let
            grpSize : Int
            grpSize =
                total // n
        in
            grpSize :: (getGroupsOfVarying (n - 1) (total - grpSize))


getNextCountdown : Int -> Msg -> ( Int, Cmd Msg )
getNextCountdown countdown msg =
    let
        newCountdown : Int
        newCountdown =
            countdown - 1
    in
        if newCountdown < 0 then
            ( 0, Cmd.none )
        else
            let
                cmd =
                    Process.sleep Time.second |> Task.perform (\_ -> msg)
            in
                ( newCountdown, cmd )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetParticipants participants ->
            ( { model | participants = participants }, Cmd.none )

        StartItemsCreation ->
            ( model, Task.perform (\_ -> StartCreationTick) Time.now )

        StartCreationTick ->
            let
                nextCountdown =
                    getNextCountdown model.itemsCreationCountdown StartCreationTick
            in
                ( { model | itemsCreationCountdown = Tuple.first nextCountdown }, Tuple.second nextCountdown )

        StartItemsGrouping ->
            ( model, Task.perform (\_ -> StartGroupingTick) Time.now )

        StartGroupingTick ->
            let
                nextCountdown =
                    getNextCountdown model.itemsGroupingCountdown StartGroupingTick
            in
                ( { model | itemsGroupingCountdown = Tuple.first nextCountdown }, Tuple.second nextCountdown )

        GenerateGroups ->
            let
                cmd : Cmd Msg
                cmd =
                    Random.generate ShuffledThemes (Random.List.shuffle model.themes)
            in
                ( model, cmd )

        ShuffledThemes themes ->
            let
                cmd : Cmd Msg
                cmd =
                    Random.generate ShuffledGroups (Random.List.shuffle model.participants)
            in
                ( { model | themes = themes }, cmd )

        ShuffledGroups participants ->
            let
                nbGroups : Int
                nbGroups =
                    List.length model.themes

                totalParticipants : Int
                totalParticipants =
                    List.length participants

                rdmParticipants : List (List String)
                rdmParticipants =
                    List.Extra.groupsOfVarying (getGroupsOfVarying nbGroups totalParticipants) participants

                themedGroups : ThemedGroups
                themedGroups =
                    List.Extra.zip model.themes rdmParticipants
            in
                ( { model | themedGroups = Just themedGroups }, Cmd.none )

        RemoveParticipant participant ->
            ( { model | participants = (List.Extra.remove participant model.participants) }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    getParticipants GetParticipants


view : Model -> Html Msg
view model =
    div [ class "container" ]
        ([ h1 [] [ text "4L Retrospective" ]
         , renderSetParticipantsStorage model
         ]
            ++ if not (List.isEmpty model.participants) then
                ([ removableParticipantsListWithTitle model.participants
                 , button [ class "btn btn-primary btn-large", onClick StartItemsCreation, disabled (model.itemsCreationCountdown < initialItemsCreationCountdown) ] [ text "Start" ]
                 , countdown model.itemsCreationCountdown
                 , button [ class "btn btn-primary btn-large", onClick GenerateGroups ] [ text "Generate groups" ]
                 , themedGroups model.themedGroups
                 ]
                    ++ (renderStartGroupingButton model)
                )
               else
                []
        )


renderStartGroupingButton : Model -> List (Html Msg)
renderStartGroupingButton model =
    case model.themedGroups of
        Just _ ->
            [ button [ class "btn btn-primary btn-large", onClick StartItemsGrouping, disabled (model.itemsGroupingCountdown < initialItemsGroupingCountdown) ] [ text "Start grouping items" ]
            , countdown model.itemsGroupingCountdown
            ]

        Nothing ->
            [ text "" ]


renderSetParticipantsStorage : Model -> Html Msg
renderSetParticipantsStorage model =
    case model.participants of
        [] ->
            div [ class "panel panel-info" ]
                [ div [ class "panel-heading" ]
                    [ h3 [ class "panel-title" ] [ text "Information" ]
                    ]
                , div [ class "panel-body" ] [ text "You must set the `participants` key in your local storage (e.g. \"['A', 'B']\" as value)." ]
                ]

        _ ->
            text ""
