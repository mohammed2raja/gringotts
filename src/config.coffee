require.config
  baseUrl: '../src'
  paths:
    backbone: '../node_modules/backbone/backbone'
    chaplin: '../node_modules/chaplin/chaplin'

    # These are for the view helpers.
    handlebars: '../node_modules/handlebars/dist/handlebars.runtime'
    moment: '../node_modules/moment/moment'
    underscore: '../node_modules/lodash/index'
    jquery: '../node_modules/jquery/dist/jquery'
    url_join: '../node_modules/url-join/lib/url-join'

    stickit: '../node_modules/backbone.stickit/backbone.stickit'
    backbone_validation:
      '../node_modules/backbone-validation/dist/backbone-validation-amd'

    # Bootstrap plugins
    bootstrap_button: '../node_modules/bootstrap/js/button'
    bootstrap_collapse: '../node_modules/bootstrap/js/collapse'
    bootstrap_dropdown: '../node_modules/bootstrap/js/dropdown'
    bootstrap_modal: '../node_modules/bootstrap/js/modal'
    bootstrap_tab: '../node_modules/bootstrap/js/tab'
    bootstrap_tooltip: '../node_modules/bootstrap/js/tooltip'
    bootstrap_transition: '../node_modules/bootstrap/js/transition'

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
    bootstrap_tooltip:
      deps: ['jquery']
    bootstrap_tab:
      deps: ['jquery']
    bootstrap_transition:
      deps: ['jquery']

    backbone_validation:
      deps: ['backbone']
