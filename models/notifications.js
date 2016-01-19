(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Collection, Notifications;
    Collection = require('./base/collection');
    return Notifications = (function(superClass) {
      extend(Notifications, superClass);

      function Notifications() {
        return Notifications.__super__.constructor.apply(this, arguments);
      }

      Notifications.prototype.initialize = function() {
        Notifications.__super__.initialize.apply(this, arguments);
        return this.subscribeEvent('notify', function(message, opts) {
          this.remove(this.where({
            message: message
          }));
          return this.add({
            message: message,
            opts: opts
          });
        });
      };

      return Notifications;

    })(Collection);
  });

}).call(this);
