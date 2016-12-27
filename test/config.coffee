require.config
  paths:
    mocha: '../node_modules/mocha/mocha'
    blanket: '../node_modules/blanket/dist/qunit/blanket'
    'mocha-blanket': '../node_modules/grunt-mocha-blanket/support/mocha-blanket'
    chai: '../node_modules/chai/chai'
    'chai-jquery': '../node_modules/chai-jquery/chai-jquery'
    sinon: '../node_modules/sinon/pkg/sinon'
    'sinon-chai': '../node_modules/sinon-chai/lib/sinon-chai'
  shim:
    'blanket':
      deps: ['mocha']
      init: ->
        # phantomjs blanket config is set in index-phantomjs.html
        window.blanket.options
          branchTracking: yes
          filter: /\/src/
          antifilter: /\/(test|templates|node_modules)/
    'mocha-blanket': ['blanket']
    'chai-jquery': ['jquery', 'chai']
    'sinon-chai': ['sinon', 'chai']
