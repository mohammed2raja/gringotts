import Chaplin from 'chaplin'
import Notifications from 'models/notifications'
import NotificationsView from 'views/notifications-view'

describe 'NotificationsView', ->
  view = null
  collection = null
  model = null

  beforeEach ->
    model = new Chaplin.Model message: 'message', opts: undo: yes
    collection = new Notifications [model]
    view = new NotificationsView {collection}

  afterEach ->
    view.dispose()
    collection.dispose()
    model.dispose()

  it 'should render a view', ->
    expect(view.$el).not.to.be.empty

  it 'should have an Undo label', ->
    expect(view.$ '.undo').to.contain I18n?.t('notifications.undo') or 'Undo'
