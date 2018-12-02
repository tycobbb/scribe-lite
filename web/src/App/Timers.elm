module Timers exposing (..)

import Process
import Task

async : m -> Cmd m
async =
  delay 17

delay : Float -> m -> Cmd m
delay time msg =
  Process.sleep (time * 1000)
    |> Task.perform (\_ -> msg)
