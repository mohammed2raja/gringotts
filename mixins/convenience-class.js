(function() {
  define(function(require) {
    var _addConvenienceClass, utils;
    utils = require('../lib/utils');

    /**
     * Adds on a convenience class for QE purposes.
     * Based on the template property.
     */
    _addConvenienceClass = function() {
      return this.className = utils.convenienceClass(this.className, this.template);
    };
    return function() {
      this.before('_ensureElement', _addConvenienceClass);
      return this;
    };
  });

}).call(this);
