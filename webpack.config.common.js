'use strict';

const webpack = require('webpack');
const {join, resolve} = require('path');

const alias = {
  handlebars: 'handlebars/runtime',
  stickit: 'backbone.stickit'
};

const coffeeLoader = {
  test: /\.coffee$/,
  loader: 'coffee-loader'
};

const handlebarsLoader = {
  test: /\.hbs$/, loader: 'handlebars-loader',
  query: {
    helperDirs: [
      join(__dirname, 'templates', 'helpers')
    ],
    partialDirs: [
      join(__dirname, 'templates', 'partials')
    ]
  }
};

const jQueryLoader = {
  test: require.resolve('jquery'),
  use: [{
    loader: 'expose-loader',
    options: 'jQuery'
  },{
    loader: 'expose-loader',
    options: '$'
  }]
};

const modules = [
  resolve(__dirname),
  resolve(__dirname, 'templates'),
  resolve(__dirname, 'node_modules')
];

const nodeMocks = {
  dgram: 'empty',
  fs: 'empty',
  net: 'empty',
  tls: 'empty'
};

const provideModules = {
  _: 'lodash',
  Backbone: 'backbone'
};

module.exports = {
  alias: alias,
  coffeeLoader: coffeeLoader,
  handlebarsLoader: handlebarsLoader,
  jQueryLoader: jQueryLoader,
  modules: modules,
  nodeMocks: nodeMocks,
  provideModules: provideModules
};
