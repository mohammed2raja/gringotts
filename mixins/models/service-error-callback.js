(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper;
    helper = require('../../lib/mixin-helper');
    return function(superclass) {
      var ServiceErrorCallback;
      return ServiceErrorCallback = (function(superClass) {
        extend(ServiceErrorCallback, superClass);

        function ServiceErrorCallback() {
          return ServiceErrorCallback.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(ServiceErrorCallback.prototype, 'ServiceErrorCallback');

        ServiceErrorCallback.prototype.initialize = function() {
          helper.assertModelOrCollection(this);
          return ServiceErrorCallback.__super__.initialize.apply(this, arguments);
        };

        ServiceErrorCallback.prototype.sync = function() {
          this.serviceErrorCallback.apply(this, arguments);
          return ServiceErrorCallback.__super__.sync.apply(this, arguments);
        };

        ServiceErrorCallback.prototype.serviceErrorCallback = function(method, model, options) {
          var callback;
          if (!options) {
            return;
          }
          callback = options.error;
          return options.error = (function(_this) {
            return function($xhr) {
              var ctx;
              if ($xhr.statusText !== 'abort' || $xhr.statusText === 'error') {
                ctx = options.context || _this;
                if (callback != null) {
                  callback.apply(ctx, arguments);
                }
                if (typeof _this.abortSync === "function") {
                  _this.abortSync();
                }
                _this.trigger('service-unavailable');
                return $xhr.errorHandled = true;
              }
            };
          })(this);
        };

        return ServiceErrorCallback;

      })(superclass);
    };
  });

}).call(this);
