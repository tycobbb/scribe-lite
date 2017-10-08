port module Stylesheets exposing (files, main)

import Css
import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Css.Normalize
import Styles.Global
import Story.Styles
import Story.Line.Styles
import Thanks.Styles

port files : CssFileStructure -> Cmd msg

vendored : List Css.Stylesheet
vendored =
  [ Css.Normalize.css
  ]

modules : List Css.Stylesheet
modules =
  List.map .css
    [ Styles.Global.styles
    , Story.Styles.styles
    , Story.Line.Styles.styles
    , Thanks.Styles.styles
    ]

cssFiles : CssFileStructure
cssFiles =
  Css.File.toFileStructure
    [ ("app.css", Css.File.compile (vendored ++ modules))
    ]

main : CssCompilerProgram
main =
  Css.File.compiler files cssFiles
