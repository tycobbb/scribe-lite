import webpack from "webpack"
import devMiddleware from "webpack-dev-middleware"
import hotMiddleware from "webpack-hot-middleware"
import config from "../../webpack.config"

export class HotReloading {
  get middleware() {
    const middleware = []
    const compiler = webpack(config)

    middleware.push(devMiddleware(compiler, {
      logLevel:   "warn",
      publicPath: config.output!.publicPath!
    }))

    middleware.push(hotMiddleware(compiler, {
      // tslint:disable-next-line:no-console
      log:       console.log,
      path:      "/__webpack_hmr",
      heartbeat: 10 * 1000
    }))

    return middleware
  }
}
