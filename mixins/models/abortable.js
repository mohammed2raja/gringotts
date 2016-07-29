(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var ActiveSyncMachine, helper, utils;
    utils = require('lib/utils');
    helper = require('../helper');
    ActiveSyncMachine = require('./active-sync-machine');

    /**
     * Aborts the existing fetch request if a new one is being requested.
     */
    return function(base) {
      var Abortable;
      return Abortable = (function(superClass) {
        extend(Abortable, superClass);

        function Abortable() {
          return Abortable.__super__.constructor.apply(this, arguments);
        }

        Abortable.prototype.initialize = function() {
          helper.assertModelOrCollection(this);
          return Abortable.__super__.initialize.apply(this, arguments);
        };

        Abortable.prototype.fetch = function() {
          var $xhr;
          $xhr = Abortable.__super__.fetch.apply(this, arguments);
          if (this.currentXHR && _.isFunction(this.currentXHR.abort) && this.isSyncing()) {
            this.currentXHR.fail(function($xhr) {
              if ($xhr.status === 0) {
                return $xhr.errorHandled = true;
              }
            }).abort();
          }
          return this.currentXHR = $xhr ? $xhr.always((function(_this) {
            return function() {
              return delete _this.currentXHR;
            };
          })(this)) : void 0;
        };

        return Abortable;

      })(utils.mix(base)["with"](ActiveSyncMachine));
    };
  });

}).call(this);
