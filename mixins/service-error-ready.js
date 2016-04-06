(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    return function(superclass) {
      var ServiceErrorReady;
      return ServiceErrorReady = (function(superClass) {
        extend(ServiceErrorReady, superClass);

        function ServiceErrorReady() {
          return ServiceErrorReady.__super__.constructor.apply(this, arguments);
        }

        ServiceErrorReady.prototype.errorSelector = '.service-error';

        ServiceErrorReady.prototype.listen = {
          'service-unavailable collection': function() {
            return this.$(this.errorSelector).show();
          },
          'syncStateChange collection': function() {
            return this.$(this.errorSelector).hide();
          }
        };

        return ServiceErrorReady;

      })(superclass);
    };
  });

}).call(this);
