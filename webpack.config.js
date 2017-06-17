const path = require('path')

module.exports = {
  entry: [
    './web/static/js/app.js'
  ],
  output: {
    path: path.resolve('./priv/static/js'),
    filename: 'app.js'
  },
  resolve: {
    modules: ['node_modules'],
    extensions: ['.js', '.elm']
  },
  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      use: {
        loader: 'elm-webpack-loader',
        options: {
          cwd: path.resolve('./web/client')
        }
      }
    }],
    noParse: [/\.elm$/]
  }
}
