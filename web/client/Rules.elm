module Rules exposing (Rules, rules, merge)

import Css
import Html
import Html.Attributes

type alias Rules m = Html.Attribute m

rules : List Css.Mixin -> Rules m
rules =
  Css.asPairs >> Html.Attributes.style

merge : List (Maybe a) -> List a
merge =
  List.filterMap identity
