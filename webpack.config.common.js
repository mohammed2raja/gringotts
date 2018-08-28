'use strict';

const webpack = require('webpack');
const _ = require('lodash');
const path = require('path')
const {join, resolve} = require('path');

const alias = {
  handlebars: 'handlebars/runtime',
  stickit: 'backbone.stickit'
};

const babelDefaultOptions = {
  cacheDirectory: true,
  caller: {
    name: 'babel-loader',
    // TODO: we stick to CommonJS for now, due to uncertain ways of mocking
    // immutable ESM exports during unit testing
    supportsStaticESM: false
  }
};

const babelLoader = {
  test: /\.coffee$/,
  loader: 'babel-loader',
  options: babelDefaultOptions
};

// Only for prod builds with old browsers support
const babelNpmLoader = {
  test: /\.js$/,
  include: [
    resolve(__dirname, 'node_modules', 'sinon')
    // Add here any NPM module that has JS syntax that needs to be babelled
  ],
  loader: 'babel-loader',
  // we should force using gringotts' .babelrc for all NPM modules because they
  // could have their own .babelrc which we want to override
  options: _.extend({}, babelDefaultOptions, {
    babelrc: false,
    compact: false,
    sourceType: 'unambiguous',
    extends: path.join(`${__dirname}/.babelrc`)
  })
};

const coffeeLoader = {
  test: /\.coffee$/,
  loader: 'coffee-loader'
};

const handlebarsLoader = {
  test: /\.hbs$/,
  loader: 'handlebars-loader',
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
  alias,
  babelLoader,
  babelNpmLoader,
  coffeeLoader,
  handlebarsLoader,
  jQueryLoader,
  modules,
  nodeMocks,
  provideModules
};
