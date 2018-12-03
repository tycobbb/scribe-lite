module Route exposing (Route(..), toRoute)

import Url exposing (Url)
import Url.Parser as P exposing (Parser)

type Route
  = Story
  | Thanks
  | NotFound

toRoute : Url -> Route
toRoute url =
  P.parse routes url
    |> Maybe.withDefault NotFound

routes : Parser (Route -> a) a
routes =
  P.oneOf
    [ P.map Story  (P.top)
    , P.map Thanks (P.s "thanks")
    ]
