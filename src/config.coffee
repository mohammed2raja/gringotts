# The dependencies for Gringotts.

require.config
  baseUrl: '../src'
  paths:
    backbone: '../vendor/bower/backbone/backbone'
    chaplin: '../vendor/bower/chaplin/chaplin'

    # These are for the view helpers.
    handlebars: '../vendor/bower/handlebars/handlebars.runtime'
    moment: '../vendor/bower/moment/moment'
    underscore: '../vendor/bower/lodash/lodash'
    jquery: '../vendor/bower/jquery/dist/jquery'

    stickit: '../vendor/bower/backbone.stickit/backbone.stickit'
    backbone_validation:
      '../vendor/bower/backbone-validation/dist/backbone-validation-amd'

    # Bootstrap plugins
    bootstrap_button: '../vendor/bower/bootstrap/js/button'
    bootstrap_collapse: '../vendor/bower/bootstrap/js/collapse'
    bootstrap_dropdown: '../vendor/bower/bootstrap/js/dropdown'
    bootstrap_modal: '../vendor/bower/bootstrap/js/modal'
    bootstrap_select:
      '../vendor/bower/bootstrap-select/dist/js/bootstrap-select'
    bootstrap_tab: '../vendor/bower/bootstrap/js/tab'
    bootstrap_tooltip: '../vendor/bower/bootstrap/js/tooltip'
    bootstrap_transition: '../vendor/bower/bootstrap/js/transition'

  shim:
    handlebars:
      exports: 'Handlebars'

    bootstrap_button:
      deps: ['jquery']
    bootstrap_collapse:
      deps: ['jquery']
    bootstrap_dropdown:
      deps: ['jquery']
    bootstrap_modal:
      deps: ['jquery']
    bootstrap_select:
      deps: ['jquery']
    bootstrap_tooltip:
      deps: ['jquery']
    bootstrap_tab:
      deps: ['jquery']
    bootstrap_transition:
      deps: ['jquery']

    backbone_validation:
      deps: ['backbone']
    'ext/bootstrap-select':
      deps: ['bootstrap_select']
