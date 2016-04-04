(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    return function(superclass) {
      var ErrorToggleView;
      return ErrorToggleView = (function(superClass) {
        extend(ErrorToggleView, superClass);

        function ErrorToggleView() {
          return ErrorToggleView.__super__.constructor.apply(this, arguments);
        }

        ErrorToggleView.prototype.listen = {
          'service-unavailable collection': function() {
            return this.$(this._errorSelector()).show();
          },
          'syncStateChange collection': function() {
            return this.$(this._errorSelector()).hide();
          }
        };

        ErrorToggleView.prototype._errorSelector = function() {
          return this.errorSelector || '.service-error';
        };

        return ErrorToggleView;

      })(superclass);
    };
  });

}).call(this);
