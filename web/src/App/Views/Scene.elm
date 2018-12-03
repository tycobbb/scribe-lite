module Views.Scene exposing (view, viewContent)

import Css exposing (..)
import Html.Styled as H exposing (Html)
import Styles.Colors as Colors

view : List (H.Attribute m) -> List (Html m) -> Html m
view =
  H.styled H.section
    [ displayFlex
    , flexDirection column
    , width (vw 100)
    , height (vh 100)
    , minHeight minContent
    ]

viewContent : List (H.Attribute m) -> List (Html m) -> Html m
viewContent =
  H.styled H.div
    [ displayFlex
    , flexDirection column
    , margin2 (px 60) (px 85)
    ]
