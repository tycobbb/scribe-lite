port module Stylesheets exposing (files, main)

import Css
import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Css.Normalize
import GlobalStyles as Global
import MainStyles as Main
import FieldStyles as Field

port files : CssFileStructure -> Cmd msg

modules : List Css.Stylesheet
modules =
  [ Css.Normalize.css
  , Global.css
  , Main.css
  , Field.css
  ]

cssFiles : CssFileStructure
cssFiles =
  Css.File.toFileStructure
    [ ("app.css", Css.File.compile modules)
    ]

main : CssCompilerProgram
main =
  Css.File.compiler files cssFiles
