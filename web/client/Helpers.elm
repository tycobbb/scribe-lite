module Helpers exposing (updateField)

updateField : (a -> b -> c) -> (d -> e) -> a -> (b, Cmd d) -> (c, Cmd e)
updateField updater action model (submodel, cmd) =
  (updater model submodel, Cmd.map (\a -> action a) cmd)
