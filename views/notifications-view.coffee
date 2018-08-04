import CollectionView from './base/collection-view'
import Notification from './notification-view'

export default class NotificationsView extends CollectionView
  itemView: Notification
  tagName: 'ul'
  container: '#notifications-container'
  className: 'list-unstyled'
