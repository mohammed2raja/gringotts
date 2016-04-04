(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var utils;
    utils = require('../lib/utils');
    return function(superclass) {
      var ConvenienceClass;
      return ConvenienceClass = (function(superClass) {
        extend(ConvenienceClass, superClass);

        function ConvenienceClass() {
          return ConvenienceClass.__super__.constructor.apply(this, arguments);
        }

        ConvenienceClass.prototype._ensureElement = function() {
          this.addConvenienceClass();
          return ConvenienceClass.__super__._ensureElement.apply(this, arguments);
        };


        /**
         * Adds on a convenience class for QE purposes.
         * Based on the template property.
         */

        ConvenienceClass.prototype.addConvenienceClass = function() {
          return this.className = utils.convenienceClass(this.className, this.template);
        };

        return ConvenienceClass;

      })(superclass);
    };
  });

}).call(this);
