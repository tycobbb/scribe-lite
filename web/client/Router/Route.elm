module Router.Route exposing (Route(..), route)

import Navigation
import UrlParser as Url exposing ((</>), s, top)

-- route parsing
type Route
  = Story
  | Thanks

route : Navigation.Location -> Route
route location =
  location
    |> Url.parsePath routes
    |> Maybe.withDefault Story

routes : Url.Parser (Route -> c) c
routes =
  Url.oneOf
    [ Url.map Story top
    , Url.map Thanks (s "thanks")
    ]
