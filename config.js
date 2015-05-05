(function() {
  require.config({
    paths: {
      chaplin: '../vendor/bower/chaplin/chaplin',
      flight: '../vendor/bower/flight/lib',
      handlebars: '../vendor/bower/handlebars/handlebars.runtime',
      moment: '../vendor/bower/moment/moment'
    },
    shim: {
      handlebars: {
        exports: 'Handlebars'
      }
    },
    map: {
      '*': {
        'flight/debug': 'lib/utils',
        'flight/utils': 'lib/utils'
      }
    }
  });

}).call(this);
