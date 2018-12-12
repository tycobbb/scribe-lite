import webpack from "webpack"

const config: webpack.Configuration = {
  mode: "development",
  context: __dirname,
  entry: [
    "webpack-hot-middleware/client?path=/__webpack_hmr&timeout=20000",
    "./src/Client/index.ts"
  ],
  output: {
    path: __dirname,
    publicPath: "/",
    filename: "bundle.js"
  },
  resolve: {
    extensions: [
      ".js", ".ts", ".elm"
    ]
  },
  module: {
    rules: [{
      test: /\.ts$/,
      exclude: [/node_modules/],
      use: [{
        loader: "ts-loader"
      }]
    }, {
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      use: [{
        loader: "elm-hot-webpack-loader"
      }, {
        loader: "elm-webpack-loader",
        options: {
          cwd:   __dirname,
          debug: true,
          forceWatch: true
        }
      }]
    }]
  },
  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
  ]
}

export default config
