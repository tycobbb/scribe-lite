module Main exposing (main)

import Html exposing (..)
import MainStyles exposing (Classes(..), styles)
import Compose.Compose as Compose

main : Program Never Model Action
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }

-- model
type alias Model =
  { compose: Compose.Model
  }

init : (Model, Cmd Action)
init =
  let
    (compose, composeCmd) = Compose.init
  in
    ( { compose = compose
      }
    , Cmd.map ComposeAction composeCmd
    )

-- update
type Action
  = ComposeAction Compose.Action

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    ComposeAction action ->
      Compose.update action model.compose
        |> setCompose model

setCompose : Model -> (Compose.Model, Cmd Compose.Action) -> (Model, Cmd Action)
setCompose model (field, cmd) =
  ({ model | compose = field }, Cmd.map ComposeAction cmd)

-- view
{ class } = styles

view : Model -> Html Action
view model =
  div [ class Container ]
    [ Compose.view model.compose
        |> Html.map ComposeAction
    ]
