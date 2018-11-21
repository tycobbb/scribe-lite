import Elm from '../App/Main'

const main = document.querySelector('#app-root')
if (main) {
  Elm.Main.embed(main)
}
