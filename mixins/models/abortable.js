(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');

    /**
     * Aborts the existing fetch request if a new one is being requested.
     */
    return function(superclass) {
      var Abortable;
      return Abortable = (function(superClass) {
        extend(Abortable, superClass);

        function Abortable() {
          return Abortable.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(Abortable.prototype, 'Abortable');

        Abortable.prototype.initialize = function() {
          helper.assertModelOrCollection(this);
          return Abortable.__super__.initialize.apply(this, arguments);
        };

        Abortable.prototype.fetch = function() {
          if (this.currentXHR) {
            this.currentXHR.abort();
          }
          return this.currentXHR = utils.abortable(Abortable.__super__.fetch.apply(this, arguments), {
            then: (function(_this) {
              return function(r, s, $xhr) {
                delete _this.currentXHR;
                return $xhr;
              };
            })(this)
          });
        };

        Abortable.prototype.sync = function(method, model, options) {
          var error;
          if (options == null) {
            options = {};
          }
          error = options.error;
          options.error = function($xhr) {
            if ($xhr.statusText !== 'abort') {
              return error != null ? error.apply(this, arguments) : void 0;
            }
          };
          return Abortable.__super__.sync.apply(this, arguments);
        };

        return Abortable;

      })(superclass);
    };
  });

}).call(this);
