import Elm from './main'

const root = document.querySelector('#root')
if (root) {
  Elm.Main.embed(root)
}
