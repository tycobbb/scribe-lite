module Helpers exposing (..)

import Socket.Event exposing (Event)

-- Effects
withoutEffects : a -> ( a, Cmd m, Event m )
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
joinCmd otherCmd (model, cmd) =
  ( model
  , Cmd.batch [ cmd , otherCmd ]
  )

-- Socket.Event
withEvent : Event m -> ( a, Cmd m ) -> ( a, Cmd m, Event m )
withEvent event ( model, cmd ) =
  ( model, cmd, event )

withoutEvent : ( a, Cmd m ) -> ( a, Cmd m, Event m )
withoutEvent =
  withEvent Socket.Event.none
