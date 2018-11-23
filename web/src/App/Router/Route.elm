module Router.Route exposing (Route(..), route)

import Url exposing (Url)
import Url.Parser as Parser

-- route parsing
type Route
  = Story
  | Thanks
  | NotFound

toRoute : Url -> Route
toRoute url =
  Parser.parse route url
    |> Maybe.withDefault NotFound

route : Parser.Parser (Route -> a) a
route =
  Parser.oneOf
    [ Parser.map Story Parser.top
    , Parser.map Thanks (Parser.s "thanks")
    ]
