port module Stylesheets exposing (files, main)

import Css
import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Css.Normalize
import MainStyles as Main
import Styles.Global as Global
import Views.Button as Button
import Scenes.Story.Styles as Story
import Scenes.Story.Line.Styles as StoryLine
import Scenes.Thanks.Styles as Thanks

port files : CssFileStructure -> Cmd msg

vendored : List Css.Stylesheet
vendored =
  [ Css.Normalize.css
  ]

modules : List Css.Stylesheet
modules =
  List.map .css
    [ Global.styles
    , Button.styles
    , Main.styles
    , Story.styles
    , StoryLine.styles
    , Thanks.styles
    ]

cssFiles : CssFileStructure
cssFiles =
  Css.File.toFileStructure
    [ ("app.css", Css.File.compile (vendored ++ modules))
    ]

main : CssCompilerProgram
main =
  Css.File.compiler files cssFiles
