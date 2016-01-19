(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, Model, advice, safeAjaxCallback, serviceUnavailable, syncFetch;
    Chaplin = require('chaplin');
    advice = require('../../mixins/advice');
    safeAjaxCallback = require('../../mixins/safe-ajax-callback');
    serviceUnavailable = require('../../mixins/service-unavailable');
    syncFetch = require('../../mixins/sync-fetch');
    return Model = (function(superClass) {
      extend(Model, superClass);

      function Model() {
        return Model.__super__.constructor.apply(this, arguments);
      }

      _.extend(Model.prototype, Chaplin.SyncMachine);

      _.each([advice, safeAjaxCallback, serviceUnavailable, syncFetch], function(mixin) {
        return mixin.call(this.prototype);
      }, Model);

      return Model;

    })(Chaplin.Model);
  });

}).call(this);
