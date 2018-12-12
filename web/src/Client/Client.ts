import { Elm } from "../App/Main"
import { Socket } from "./Socket"

const app = Elm.Main.init({
  node:  document.querySelector("#app-root"),
  flags: null
})

const socket = new Socket(
  app.ports.send,
  app.ports.recv
)

socket.start()
