(function() {
  define(function(require) {
    return {

      /**
       * Activates Chaplin.SyncMachine on an object
       * @param  {Backbone.Events} obj an instinace of Model or Collection
       * @param  {Bool} listenAll to listen events from nested models
       */
      activateSyncMachine: function(listenAll) {
        if (listenAll == null) {
          listenAll = false;
        }
        if (!this.on) {
          throw new Error('obj must have Backbone.Events mixed-in');
        }
        return _.each([
          {
            event: 'request',
            listener: 'beginSync'
          }, {
            event: 'sync',
            listener: 'finishSync'
          }, {
            event: 'error',
            listener: 'unsync'
          }
        ], function(map) {
          return this.on(map.event, function(model) {
            if (this === model || listenAll) {
              return this[map.listener]();
            }
          });
        }, this);
      }
    };
  });

}).call(this);
