define (require) ->
  CollectionView = require './base/collection-view'
  Notification = require './notification-view'

  class NotificationsView extends CollectionView
    itemView: Notification
    tagName: 'ul'
    container: '#notifications-container'
    className: 'unstyled'
