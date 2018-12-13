module Timers exposing (async, delay)

import Process
import Task

async : m -> Cmd m
async =
  delay 17

delay : Float -> m -> Cmd m
delay time msg =
  Process.sleep time
    |> Task.perform (always msg)
