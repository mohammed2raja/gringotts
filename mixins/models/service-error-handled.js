(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper, utils;
    utils = require('lib/utils');
    helper = require('../../lib/mixin-helper');

    /**
     * Sets XHR errors on fetch as handled,
     * to suppress further error notification.
     * This mixin is useful for Collections that are being used by views
     * with ServiceErrorReady applied.
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
          helper.assertCollection(this);
          helper.assertNotModel(this);
          return ServiceErrorHandled.__super__.initialize.apply(this, arguments);
        };

        ServiceErrorHandled.prototype.fetch = function() {
          return utils.abortable(ServiceErrorHandled.__super__.fetch.apply(this, arguments), {
            "catch": function() {}
          });
        };

        return ServiceErrorHandled;

      })(superclass);
    };
  });

}).call(this);
