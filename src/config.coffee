# The dependencies for Gringotts.

require.config
  paths:
    chaplin: '../vendor/bower/chaplin/chaplin'
    # We use `flight/advice` for AOP.
    flight: '../vendor/bower/flight/lib'

    # These are for the view helpers.
    handlebars: '../vendor/bower/handlebars/handlebars.runtime'
    moment: '../vendor/bower/moment/moment'

  shim:
    handlebars:
      exports: 'Handlebars'

  map:
    # Stub out debug since we don't need it.
    '*':
      'flight/debug': 'lib/utils'
      # Advice only needs enumerable, so add it to utils.
      'flight/utils': 'lib/utils'
