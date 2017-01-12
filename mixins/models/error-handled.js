(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper;
    helper = require('../../lib/mixin-helper');
    return function(superclass) {
      var ErrorHandled;
      return ErrorHandled = (function(superClass) {
        extend(ErrorHandled, superClass);

        function ErrorHandled() {
          this.handleError = bind(this.handleError, this);
          return ErrorHandled.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(ErrorHandled.prototype, 'ErrorHandled');

        ErrorHandled.prototype.initialize = function() {
          helper.assertModelOrCollection(this);
          return ErrorHandled.__super__.initialize.apply(this, arguments);
        };


        /**
         * Generic error handler. Works with an Error and XHR instances.
         * It triggers the event that a related view with applied ErrorHandling
         * mixin will consume.
         */

        ErrorHandled.prototype.handleError = function(obj) {
          this.trigger('promise-error', this, obj);
          if (!obj.errorHandled) {
            return this.logError(obj);
          }
        };

        ErrorHandled.prototype.logError = function(obj) {
          if (!(window.console && window.console.warn)) {
            return;
          }
          window.console.warn('Warning, an error was not handled correctly');
          if (obj.status) {
            return window.console.warn('HTTP Error', obj.status, obj);
          } else {
            return window.console.warn(obj);
          }
        };

        return ErrorHandled;

      })(superclass);
    };
  });

}).call(this);
