const webpack = require('webpack');
const {join, resolve} = require('path');
const {getIfUtils, removeEmpty} = require('webpack-config-utils');
const _ = require('lodash');

const {ifProduction, ifNotProduction} = getIfUtils(process.env.NODE_ENV);

const hushCoverage = {
  statements: 0,
  lines: 0,
  branches: 0,
  functions: 0
};

module.exports = (config) => {
  config.set({
    browsers: removeEmpty([
      ifProduction('PhantomJS'),
      ifNotProduction('Chrome')
    ]),
    client: {
      mocha: {
        reporter: 'html'
      }
    },
    coverageIstanbulReporter: {
      fixWebpackSourcePaths: true,
      reports: removeEmpty(['text', ifNotProduction('html')]),
      thresholds: {
        global: {
          statements: 65,
          lines: 65,
          branches: 65,
          functions: 65
        },
        each: {
          statements: 65,
          lines: 65,
          branches: 50,
          functions: 65
        }
      }
    },
    files: [{pattern: 'test/index.coffee', watched: false}],
    frameworks: [
      'mocha',
      'sinon-chai',
      'chai-jquery',
      'chai',
      'jquery-3.1.1'
    ],
    logLevel: config.LOG_ERROR,
    port: 8000,
    plugins: removeEmpty([
      require('karma-webpack'),
      require('karma-jquery'),
      require('karma-mocha'),
      ifProduction(require('karma-spec-reporter')),
      ifNotProduction(require('karma-nyan-reporter')),
      require('karma-chai'),
      require('karma-chai-plugins'),
      ifProduction(require('karma-phantomjs-launcher')),
      ifNotProduction(require('karma-chrome-launcher')),
      require('karma-coverage-istanbul-reporter'),
      require('karma-sourcemap-loader')
    ]),
    preprocessors: {
      'test/index.coffee': ['webpack', 'sourcemap']
    },
    reporters: removeEmpty([
      ifProduction('spec'),
      ifNotProduction('nyan'),
      'coverage-istanbul'
    ]),
    singleRun: false,
    webpack: {
      devtool: ifProduction('source-map', 'eval'),
      module: {
        exprContextCritical: false,
        rules: removeEmpty([
          {
            test: /\.coffee$/,
            loader: 'coffee-loader'
          },
          {
            test: /\.coffee$/,
            enforce: 'post',
            include: /(lib|mixins|models|templates|views)/,
            loader: 'istanbul-instrumenter-loader',
            query: {
              esModules: true,
              produceSourceMap: true
            }
          },
          ifProduction({
            enforce: 'pre',
            test: /\.hbs/,
            loader: 'htmlhint-loader',
            exclude: /node_modules/,
            options: {
              failOnError: true,
              outputReport: true
            }
          }),
          {
            test: /\.hbs$/, loader: 'handlebars-loader',
            query: {
              helperDirs: [
                join(__dirname, 'templates', 'helpers')
              ],
              partialDirs: [
                join(__dirname, 'templates', 'partials')
              ]
            }
          }
        ])
      },
      node: {
        fs: 'empty'
      },
      plugins: [
        new webpack.ProvidePlugin({
          _: 'lodash',
          Backbone: 'backbone'
        })
      ],
      resolve: {
        alias: {
          handlebars: 'handlebars/runtime',
          stickit: 'backbone.stickit'
        },
        extensions: ['.coffee', '.js', '.hbs'],
        modules: [
          resolve(__dirname),
          resolve(__dirname, 'templates'),
          resolve(__dirname, 'test/templates'),
          resolve(__dirname, 'node_modules')
        ]
      },
      watchOptions: {
        ignored: /coverage\/$/
      }
    }
  });
};
