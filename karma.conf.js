const webpackConfig = require('./webpack.config.dev')

const isDebugMode = process.env.DEBUG || false

module.exports = config => {
  config.set({
    browsers: isDebugMode ? ['Chrome'] : ['PhantomJS'],
    client: isDebugMode ? {mocha: {reporter: 'html'}} : {},
    coverageIstanbulReporter: {
      fixWebpackSourcePaths: true,
      reports: isDebugMode ? ['text', 'html'] : ['text'],
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
          branches: 45,
          functions: 65
        }
      }
    },
    files: ['index.spec.coffee'],
    frameworks: ['mocha', 'sinon-chai', 'chai-jquery', 'chai', 'jquery-3.3.1'],
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
      'index.spec.coffee': ['webpack', 'sourcemap']
    },
    reporters: ['dots', 'coverage-istanbul'],
    singleRun: !isDebugMode,
    webpack: {
      ...webpackConfig,
      // for istanbul code coverage, 'cheap-module-source-map' is required
      devtool: isDebugMode ? 'eval' : 'cheap-module-source-map',
      module: {
        ...webpackConfig.module,
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
          ...webpackConfig.module.rules,
          {
            test: /\.coffee$/,
            enforce: 'post',
            exclude: /node_modules|\.spec\.coffee$/,
            use: {
              loader: 'istanbul-instrumenter-loader',
              options: {esModules: true}
            }
          }
        ]
      }
    }
  })
}
