(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    return function(superclass) {
      var OverrideXHR;
      return OverrideXHR = (function(superClass) {
        extend(OverrideXHR, superClass);

        function OverrideXHR() {
          return OverrideXHR.__super__.constructor.apply(this, arguments);
        }

        OverrideXHR.prototype.fetch = function() {
          return this.overrideXHR(OverrideXHR.__super__.fetch.apply(this, arguments));
        };


        /**
         * Aborts the existing request if a new one is being requested.
         */

        OverrideXHR.prototype.overrideXHR = function($xhr) {
          var base;
          if (this.currentXHR && this.isSyncing()) {
            if (typeof (base = this.currentXHR).abort === "function") {
              base.abort();
            }
          }
          return this.currentXHR = $xhr;
        };

        return OverrideXHR;

      })(superclass);
    };
  });

}).call(this);
