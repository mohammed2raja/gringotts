const _ = require('lodash')
const webpackConfig = require('./webpack.config.dev')

const isDebugMode = process.env.DEBUG || false
const reportHtmlCoverage = process.env.HTML_COVERAGE || false

module.exports = config => {
  config.set({
    browsers: isDebugMode ? ['Chrome'] : ['PhantomJS'],
    client: {mocha: {reporter: 'html'}},
    coverageIstanbulReporter: {
      fixWebpackSourcePaths: true,
      reports: reportHtmlCoverage ? ['text', 'html'] : ['text'],
      thresholds: {
        global: {
          statements: 90,
          lines: 90,
          branches: 80,
          functions: 90
        },
        each: {
          statements: 65,
          lines: 65,
          branches: 0,
          functions: 0
        }
      }
    },
    files: ['index.spec.coffee'],
    frameworks: ['mocha'],
    plugins: [
      require('karma-webpack'),
      require('karma-mocha'),
      require('karma-spec-reporter'),
      isDebugMode
        ? require('karma-chrome-launcher')
        : require('karma-phantomjs-launcher'),
      require('karma-coverage-istanbul-reporter'),
      require('karma-sourcemap-loader')
    ],
    preprocessors: {
      'index.spec.coffee': ['webpack', 'sourcemap']
    },
    reporters: ['dots', 'coverage-istanbul'],
    singleRun: !isDebugMode,
    webpack: {
      ..._.omit(webpackConfig, 'entry'),
      devtool: 'inline-source-map',
      module: {
        ...webpackConfig.module,
        rules: [
          {
            test: /\.coffee$/,
            enforce: 'post',
            exclude: /node_modules|\.spec\.coffee$/,
            use: {
              loader: 'istanbul-instrumenter-loader',
              options: {esModules: true, produceSourceMap: isDebugMode}
            }
          },
          ...webpackConfig.module.rules,
          {
            enforce: 'pre',
            test: /\.hbs/,
            loader: 'htmlhint-loader',
            exclude: /node_modules/,
            options: {
              failOnError: true,
              outputReport: true
            }
          }
        ]
      }
    }
  })
}
