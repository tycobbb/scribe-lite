import path    from "path"
import webpack from "webpack"

const config: webpack.Configuration = {
  mode: "development",
  context: __dirname,
  entry: [
    "webpack-hot-middleware/client?path=/__webpack_hmr&timeout=20000",
    "./src/Client/index.js"
  ],
  output: {
    path: __dirname,
    publicPath: "/",
    filename: "bundle.js"
  },
  resolve: {
    extensions: [
      ".js", ".elm"
    ]
  },
  module: {
    noParse: /\.elm$/,
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      use: {
        loader: 'elm-webpack-loader',
        options: {
          cwd: path.resolve('./'),
          debug: true
        }
      }
    }]
  },
  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
  ]
}

export default config
