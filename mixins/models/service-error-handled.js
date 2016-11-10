(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper;
    helper = require('../../lib/mixin-helper');

    /**
     * Sets all XHR errors as handled, to suppress global error notification.
     */
    return function(superclass) {
      var ServiceErrorHandled;
      return ServiceErrorHandled = (function(superClass) {
        extend(ServiceErrorHandled, superClass);

        function ServiceErrorHandled() {
          return ServiceErrorHandled.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(ServiceErrorHandled.prototype, 'ServiceErrorHandled');

        ServiceErrorHandled.prototype.initialize = function() {
          helper.assertModelOrCollection(this);
          return ServiceErrorHandled.__super__.initialize.apply(this, arguments);
        };

        ServiceErrorHandled.prototype.sync = function(method, model, options) {
          var error;
          if (options == null) {
            options = {};
          }
          error = options.error;
          options.error = function($xhr) {
            $xhr.errorHandled = true;
            return error != null ? error.apply(this, arguments) : void 0;
          };
          return ServiceErrorHandled.__super__.sync.apply(this, arguments);
        };

        return ServiceErrorHandled;

      })(superclass);
    };
  });

}).call(this);
