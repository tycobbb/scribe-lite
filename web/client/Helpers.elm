module Helpers exposing (..)

import Process
import Task
import Time
import Socket.Event exposing (Event)

-- State
type alias State a m =
  ( a, Cmd m, Event m )

-- Indexing
type alias Indexed a m =
  ( { index : Int , model : a }, Cmd m, Event m )

withIndex : Int -> State a m -> Indexed a m
withIndex index ( model, cmd, event ) =
  ( { index = index, model = model }, cmd, event )

-- Effects
withoutEffects : a -> State a m
withoutEffects =
  withoutCmd >> withoutEvent

-- Cmd
withCmd : Cmd m -> a -> ( a, Cmd m )
withCmd cmd model =
  ( model, cmd )

withoutCmd : a -> ( a, Cmd m )
withoutCmd =
  withCmd Cmd.none

joinCmd : Cmd m -> ( a, Cmd m ) -> ( a, Cmd m )
joinCmd otherCmd ( model, cmd ) =
  ( model
  , Cmd.batch [ cmd , otherCmd ]
  )

-- Socket.Event
withEvent : Event m -> ( a, Cmd m ) -> State a m
withEvent event ( model, cmd ) =
  ( model, cmd, event )

withoutEvent : ( a, Cmd m ) -> State a m
withoutEvent =
  withEvent Socket.Event.none

-- Timers
delay : Float -> a -> Cmd a
delay time msg =
  Process.sleep (Time.millisecond * time)
    |> Task.andThen (always (Task.succeed msg))
    |> Task.perform identity

async : m -> Cmd m
async =
  delay 17
