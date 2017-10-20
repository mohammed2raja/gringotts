Classy = require '../../mixins/views/classy'
View = require './view'
NotificationsView = require '../notifications-view'
Notifications = require '../../models/notifications'

###*
  * Base View for bootstrap modals.
  * The instance of this modal view should be always added into 'subviews' of
  * the parent host Chaplin.View that initiates modal creation.
  * This will guarantee that modal view is disposed when host view is disposed.
###
module.exports = class ModalView extends Classy View
  classyName: 'modal fade'
  attributes:
    role: 'dialog'
  events:
    'shown.bs.modal': -> @onShown()
    'hidden.bs.modal': -> @onHidden()
  notifyAnchorSelector: '.modal-header'

  attach: (opts) ->
    super
    @$el.modal opts

  show: ->
    return if @disposed
    @delegateEvents()
    @delegateListeners()
    @render()
    @attach()

  notify: (message, opts) ->
    if @$el?.hasClass 'in'
      @renderNotifications()
      @notifications.addMessage message, _.extend {
        sticky: yes
      }, opts
    else
      super

  renderNotifications: ->
    unless @subview('notifications')
      notification = $ '<div>', class: 'modal-notifications'
      if @notifyAnchorSelector
        $el = @$(@notifyAnchorSelector)
        $el.after notification
      else
        $el = @$('.modal-content')
        $el.prepend notification
      @notifications = new Notifications()
      @subview 'notifications', new NotificationsView {
        collection: @notifications
        container: '.modal-notifications'
      }

  hide: ->
    return if @disposed
    @$el.modal 'hide' if @$el and @$el.hasClass 'in'

  onShown: ->
    @modalVisible = yes
    # Globally prevent scrolling of page when modal is displayed
    $('body').addClass 'no-scroll'
    @trigger 'shown'

  onHidden: ->
    @modalVisible = no
    $('body').removeClass 'no-scroll'
    @trigger 'hidden'
    @remove() unless @disposed

  dispose: ->
    @notifications.dispose() if @notifications
    if @modalVisible
      @once 'hidden', -> super
      @hide()
    else
      super
