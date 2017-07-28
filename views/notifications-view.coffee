CollectionView = require './base/collection-view'
Notification = require './notification-view'

module.exports = class NotificationsView extends CollectionView
  itemView: Notification
  tagName: 'ul'
  container: '#notifications-container'
  className: 'unstyled'
