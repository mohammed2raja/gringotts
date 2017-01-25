(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper;
    helper = require('../../lib/mixin-helper');

    /**
     * Checks response JSON on every fetch and extracts items stored in "syncKey"
     * property name. Most of the time it's used for so call responses with
     * metadata. When you need to pass from server set of items and extra info
     * like total elements count or next page id. Example:
     * {
     *   count: 55
     *   description: "Some elements from server"
     *   elements: [
     *     {id: 0}
     *     {id: 1}
     *   ]
     * }
     * @param  {Collection}  superclass
     */
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var SyncKey;
        return SyncKey = (function(superClass) {
          extend(SyncKey, superClass);

          function SyncKey() {
            return SyncKey.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(SyncKey.prototype, 'SyncKey');


          /**
           * Name of the property in response JSON that carries an array of items.
           * @type {String}
           */

          SyncKey.prototype.syncKey = null;

          SyncKey.prototype.initialize = function() {
            helper.assertCollection(this);
            return SyncKey.__super__.initialize.apply(this, arguments);
          };

          SyncKey.prototype.parse = function() {
            var result;
            result = SyncKey.__super__.parse.apply(this, arguments);
            if (this.syncKey) {
              return result[this.syncKey];
            } else {
              return result;
            }
          };

          return SyncKey;

        })(superclass);
      });
    };
  });

}).call(this);
