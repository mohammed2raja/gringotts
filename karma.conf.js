const webpack = require('webpack');
const _ = require('lodash');
const {
  alias,
  extensions,
  babelLoader,
  babelNpmLoader,
  coffeeLoader,
  handlebarsLoader,
  modules,
  nodeMocks,
  provideModules
} = require('./webpack.config.common');

const isDebugMode = process.env.DEBUG || false
const reportHtmlCoverage = process.env.HTML_COVERAGE || false

module.exports = (config) => {
  config.set({
    browsers: isDebugMode
      ? ['Chrome']
      : ['PhantomJS'],
    client: isDebugMode
      ? {
          mocha: {
            reporter: 'html'
          }
        }
      : {},
    coverageIstanbulReporter: {
      fixWebpackSourcePaths: true,
      reports: reportHtmlCoverage ? ['text', 'html'] : ['text'],
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
          branches: 45,
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
      'jquery-3.3.1'
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
      isDebugMode
        ? require('karma-chrome-launcher')
        : require('karma-phantomjs-launcher'),
      require('karma-coverage-istanbul-reporter'),
      require('karma-sourcemap-loader')
    ],
    preprocessors: {
      'spec/index.coffee': ['webpack', 'sourcemap']
    },
    reporters: ['dots', 'coverage-istanbul'],
    singleRun: !isDebugMode,
    webpack: {
      devtool: 'eval',
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
          babelLoader,
          babelNpmLoader,
          coffeeLoader,
          handlebarsLoader,
          {
            test: /\.coffee$/,
            enforce: 'post',
            include: /(lib|mixins|models|templates|views)/,
            exclude: /\.spec\.coffee$/,
            loader: 'istanbul-instrumenter-loader'
          },
        ]
      },
      node: nodeMocks,
      mode: 'development',
      plugins: [
        // Moment.js bundles large locale files by default due to how Webpack
        // interprets its code. This is a practical solution that requires the
        // user to opt into importing specific locales.
        // https://github.com/jmblog/how-to-optimize-momentjs-with-webpack
        new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/),
        new webpack.ProvidePlugin(provideModules)
      ],
      resolve: {
        alias,
        extensions,
        modules
      },
      watchOptions: {
        aggregateTimeout: 500
      }
    }
  });
};
