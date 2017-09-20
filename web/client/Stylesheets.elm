port module Stylesheets exposing (files, main)

import Css
import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Css.Normalize
import Styles.Global
import MainStyles
import FieldStyles

port files : CssFileStructure -> Cmd msg

vendored : List Css.Stylesheet
vendored =
  [ Css.Normalize.css
  ]

modules : List Css.Stylesheet
modules =
  List.map .css
    [ Styles.Global.styles
    , MainStyles.styles
    , FieldStyles.styles
    ]

cssFiles : CssFileStructure
cssFiles =
  Css.File.toFileStructure
    [ ("app.css", Css.File.compile (vendored ++ modules))
    ]

main : CssCompilerProgram
main =
  Css.File.compiler files cssFiles
