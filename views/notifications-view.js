(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var CollectionView, Notification, NotificationsView;
    CollectionView = require('./base/collection-view');
    Notification = require('./notification-view');
    return NotificationsView = (function(superClass) {
      extend(NotificationsView, superClass);

      function NotificationsView() {
        return NotificationsView.__super__.constructor.apply(this, arguments);
      }

      NotificationsView.prototype.itemView = Notification;

      NotificationsView.prototype.tagName = 'ul';

      NotificationsView.prototype.container = '#notifications-container';

      NotificationsView.prototype.className = 'unstyled';

      return NotificationsView;

    })(CollectionView);
  });

}).call(this);
