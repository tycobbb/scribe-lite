const CopyPlugin = require('copy-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const path = require('path')

module.exports = {
  entry: [
    './web/static/js/app.js'
  ],
  output: {
    path: path.resolve('./priv/static'),
    filename: 'js/app.js'
  },
  resolve: {
    modules: ['node_modules'],
    extensions: ['.js', '.elm']
  },
  module: {
    noParse: /^((?!Stylesheets).)*\.elm.*$/,
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/, /Stylesheets\.elm/],
      use: {
        loader: 'elm-webpack-loader',
        options: {
          cwd: path.resolve('./')
        }
      }
    }, {
      test: /Stylesheets\.elm$/,
      use: ExtractTextPlugin.extract({
        fallback: 'style-loader',
        use: [
          'css-loader',
          'elm-css-webpack-loader'
        ]
      })
    }]
  },
  plugins: [
    new ExtractTextPlugin('./css/app.css'),
    new CopyPlugin([
      { from: './web/static/assets' }
    ])
  ]
}
