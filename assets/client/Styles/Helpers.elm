module Styles.Helpers exposing (..)

import Css
import Css.Namespace
import Html
import Html.Attributes
import Html.CssHelpers exposing (Namespace, withNamespace)

-- inline rules
type alias Rules m = Html.Attribute m

rules : List Css.Style -> Rules m
rules =
  Css.asPairs >> Html.Attributes.style

-- namespace
type alias Styles c m =
  { css : Css.Stylesheet
  , class : c -> Html.Attribute m
  , classes : List (c, Bool) -> Html.Attribute m
  }

stylesNamed : String -> List Css.Snippet -> Styles c m
stylesNamed namespace mixins =
  let
    stylesheet =
      (Css.Namespace.namespace namespace) >> Css.stylesheet
    baseNamespace =
      Html.CssHelpers.withNamespace namespace
  in
    { css = stylesheet mixins
    , class = List.singleton >> baseNamespace.class
    , classes = baseNamespace.classList
    }
