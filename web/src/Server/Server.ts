import express from "express"
import { Root } from "./Root"

export class Server {
  private port = 3000
  private app  = express()

  private async start() {
    this.setConfig()
    await this.addHotReloading()
    this.addRoutes()
    this.app.listen(this.port)

    console.log(`hosting app @ http://localhost:${this.port}`)
  }

  private setConfig() {
    this.app.set("views", __dirname)
    this.app.set("view engine",  "ejs")
  }

  private async addHotReloading() {
    const { HotReloading } = await import("./HotReloading")
    const hotReloading = new HotReloading()
    this.app.use(hotReloading.middleware)
  }

  private addRoutes() {
    this.app.get("/", Root.route)
  }

  // bootstrap
  static start() {
    const server = new Server()
    server.start()
  }
}
