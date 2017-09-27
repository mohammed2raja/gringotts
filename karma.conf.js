const webpack = require('webpack');
const {
  alias,
  coffeeLoader,
  handlebarsLoader,
  modules,
  nodeMocks,
  provideModules
} = require('./webpack.config.common');

module.exports = (config) => {
  config.set({
    browsers: ['PhantomJS'],
    coverageIstanbulReporter: {
      fixWebpackSourcePaths: true,
      reports: ['text'],
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
    files: [{pattern: 'spec/index.coffee', watched: false}],
    frameworks: [
      'mocha',
      'sinon-chai',
      'chai-jquery',
      'chai',
      'jquery-3.1.1'
    ],
    logLevel: config.LOG_ERROR,
    port: 8000,
    plugins: [
      require('karma-webpack'),
      require('karma-jquery'),
      require('karma-mocha'),
      require('karma-spec-reporter'),
      require('karma-chai'),
      require('karma-chai-plugins'),
      require('karma-phantomjs-launcher'),
      require('karma-coverage-istanbul-reporter'),
      require('karma-sourcemap-loader')
    ],
    preprocessors: {
      'spec/index.coffee': ['webpack', 'sourcemap']
    },
    reporters: ['spec', 'coverage-istanbul'],
    singleRun: true,
    webpack: {
      devtool: 'source-map',
      module: {
        exprContextCritical: false,
        noParse: /lodash|moment/,
        rules: [
          {
            enforce: 'pre',
            test: /\.hbs/,
            loader: 'htmlhint-loader',
            exclude: /node_modules/,
            options: {
              failOnError: true,
              outputReport: true
            }
          },
          coffeeLoader,
          handlebarsLoader,
          {
            test: /\.coffee$/,
            enforce: 'post',
            include: /(lib|mixins|models|templates|views)/,
            exclude: /\.spec\.coffee$/,
            loader: 'istanbul-instrumenter-loader',
            query: {
              esModules: true,
              produceSourceMap: true
            }
          },
        ]
      },
      node: nodeMocks,
      plugins: [
        new webpack.ProvidePlugin(provideModules)
      ],
      resolve: {
        alias: alias,
        extensions: ['.coffee', '.js', '.hbs'],
        modules: modules
      },
      watchOptions: {
        aggregateTimeout: 500
      }
    }
  });
};
