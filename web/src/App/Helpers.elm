module Helpers exposing (..)

import Process
import Task
import Time
import Socket

-- Types
type alias Change a m =
  { model   : a
  , effects : Effects m
  }

type alias Indexed a =
  { index : Int
  , item  : a
  }

type alias Effects m =
  ( Cmd m
  , Socket.Event m
  )

-- Change
withoutEffects : a -> Change a m
withoutEffects =
  withoutCmd >> withoutEvent

mapChange : (a -> b) -> (m -> m1) -> Change a m -> Change b m1
mapChange asModel asMsg { model, effects } =
  { model = asModel model
  , effects = mapEffects asMsg effects
  }

-- Effects
mapEffects : (m -> m1) -> Effects m -> Effects m1
mapEffects asMsg ( cmd, event ) =
  ( Cmd.map asMsg cmd
  , Socket.map asMsg event
  )

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
withEvent : Socket.Event m -> ( a, Cmd m ) -> Change a m
withEvent event ( model, cmd ) =
  { model = model
  , effects = ( cmd, event )
  }

withoutEvent : ( a, Cmd m ) -> Change a m
withoutEvent =
  withEvent Socket.unknown

-- Indexing
indexable : (Indexed a -> b) -> Int -> a -> b
indexable other index =
  (Indexed index) >> other

withIndex : Int -> Change a m -> Change (Indexed a) m
withIndex index { model, effects } =
  { model   = Indexed index model
  , effects = effects
  }

-- Timers
delay : Float -> a -> Cmd a
delay time msg =
  Process.sleep (time * 1000)
    |> Task.perform (\_ -> msg)

async : m -> Cmd m
async =
  delay 17
