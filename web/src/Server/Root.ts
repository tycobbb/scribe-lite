import { Request, Response } from "express"

export class Root {
  static route(_: Request, response: Response) {
    response.render("index", {
      content: ""
    })
  }
}
