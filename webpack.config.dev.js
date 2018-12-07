const {join, resolve} = require('path')
const webpack = require('webpack')

module.exports = {
  devServer: {
    inline: true,
    watchOptions: {ignored: /node_modules/}
  },
  entry: 'mocha-loader?enableTimeouts=false!./index.spec.coffee',
  module: {
    strictExportPresence: true,
    rules: [
      {
        test: /\.coffee|.js$/,
        loader: 'babel-loader',
        exclude: /node_modules(?!\/sinon)/,
        options: {cacheDirectory: true}
      },
      {
        test: /\.coffee$/,
        exclude: /node_modules/,
        loader: 'coffee-loader'
      },
      {
        test: /\.hbs$/,
        exclude: /node_modules/,
        loader: 'handlebars-loader',
        query: {
          helperDirs: [join(__dirname, 'templates', 'helpers')],
          partialDirs: [join(__dirname, 'templates', 'partials')]
        }
      },
      {
        test: require.resolve('jquery'),
        use: [
          {loader: 'expose-loader', options: 'jQuery'},
          {loader: 'expose-loader', options: '$'}
        ]
      }
    ]
  },
  mode: 'development',
  plugins: [new webpack.ProvidePlugin({_: 'lodash'})],
  resolve: {
    extensions: ['.coffee', '.js', '.hbs'],
    modules: [resolve(__dirname, 'node_modules')]
  }
}
