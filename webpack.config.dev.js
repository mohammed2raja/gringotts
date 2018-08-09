'use strict';

const webpack = require('webpack');
const _ = require('lodash');
const {resolve} = require('path');
const {
  alias,
  coffeeLoader,
  handlebarsLoader,
  jQueryLoader,
  modules,
  nodeMocks,
  provideModules
} = require('./webpack.config.common');

const publicDir = resolve(__dirname);
const host = process.env.HOST || 'localhost';

module.exports = {
  serve: {
    clipboard: false,
    content: publicDir,
    host: host,
    port: 8080,
    devMiddleware: {
      watchOptions: {
        ignored: /node_modules/
      }
    }
  },
  devtool: 'eval',
  entry: {
    spec: 'mocha-loader?enableTimeouts=false!./spec/index.coffee'
  },
  module: {
    strictExportPresence: true,
    rules: [
      coffeeLoader,
      handlebarsLoader,
      jQueryLoader
    ]
  },
  node: nodeMocks,
  output: {
    filename: 'javascripts/[name].js',
    path: publicDir,
    publicPath: '/'
  },
  performance: {
    hints: false
  },
  mode: 'development',
  plugins: [
    // Moment.js bundles large locale files by default due to how Webpack
    // interprets its code. This is a practical solution that requires the
    // user to opt into importing specific locales.
    // https://github.com/jmblog/how-to-optimize-momentjs-with-webpack
    new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/),
    new webpack.ProvidePlugin(provideModules),
    new webpack.LoaderOptionsPlugin({
      options: {
        coffeelint: {failOnHint: true},
        context: '/'
      }
    }),
  ],
  resolve: {
    alias: _.extend({}, alias, {
      chai: 'chai/chai',
      'chai-jquery': 'chai-jquery/chai-jquery',
      'sinon-chai': 'sinon-chai/lib/sinon-chai'
    }),
    extensions: ['.js', '.coffee', '.hbs'],
    modules: modules,
    symlinks: false
  }
};
