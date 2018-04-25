import './Stylesheets'
import Elm from './Main'

const main = document.querySelector('#container')
if (main) {
  Elm.Main.embed(main)
}
