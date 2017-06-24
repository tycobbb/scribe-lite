import '../../client/Stylesheets'
import Elm from '../../client/Main'

const main = document.querySelector('#container')
if (main) {
  Elm.Main.embed(main)
}
