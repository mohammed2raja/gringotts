(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, Collection, Model, advice, paginationStats, parseResponse, safeAjaxCallback, scopeable, serviceUnavailable, syncFetch;
    Chaplin = require('chaplin');
    Model = require('./model');
    advice = require('../../mixins/advice');
    paginationStats = require('../../mixins/pagination-stats');
    parseResponse = require('../../mixins/parse-response');
    safeAjaxCallback = require('../../mixins/safe-ajax-callback');
    serviceUnavailable = require('../../mixins/service-unavailable');
    scopeable = require('../../mixins/scopeable');
    syncFetch = require('../../mixins/sync-fetch');
    return Collection = (function(superClass) {
      extend(Collection, superClass);

      function Collection() {
        return Collection.__super__.constructor.apply(this, arguments);
      }

      _.extend(Collection.prototype, Chaplin.SyncMachine);

      _.each([advice, paginationStats, parseResponse, safeAjaxCallback, serviceUnavailable, scopeable, syncFetch], function(mixin) {
        return mixin.call(this.prototype);
      }, Collection);

      Collection.prototype.DEFAULTS = {
        page: 1,
        per_page: 30,
        order: 'asc'
      };

      Collection.prototype.model = Model;

      Collection.prototype.before('initialize', function() {
        return this.on('dispose', function(model) {
          return this.remove(model);
        });
      });

      Collection.prototype.pageString = function(stats) {
        return typeof I18n !== "undefined" && I18n !== null ? I18n.t('items.total', stats) : void 0;
      };

      return Collection;

    })(Chaplin.Collection);
  });

}).call(this);
