module Rules exposing (..)

import Css
import Html
import Html.Attributes

type alias Rules m = Html.Attribute m

rules : List Css.Mixin -> Rules m
rules =
  Css.asPairs >> Html.Attributes.style
