# This is a view with ability to display a notification
# and undo a server request by deferring it with a timeout.
#
# It requires a `model` with an `opts` attribute which should be
# an object with a `success` and `undo` key with a corresponding
# method.
#
# After `4ms`, it will remove the notification and execute the
# `success` method if provided. Pass in a `sticky` flag if you
# don't want the notification to dismiss. Sticky notifications
# only dismiss manually or on route.
#
# The action can be undone by providing a `undo()` method which
#  will be invoked when the associated element is clicked.
#
# If an associated model is provided in the `opts` object under
# the key `model`, it will listen for disposal and run `success`
# immediately.
#
# Classes can be added on an per instance basis with the `classes`
# key on `opts`.
#
# A `link` can be provided to append to the notification.
#
# A `click` handler can be provided which takes the form of an `object`
# with a key for `selector` and one for `handler` which are the arguments used
# by `@delegate`. If `undo` is true it will overwrite `click`.
#
# Fade speed, timeout length, undo selector, stickiness, whether navigate
# dismisses, link, click handler, and classes can be configured via
# overrriding of public properties.
define (require) ->
  templates = require('templates')
  View = require './base/view'

  # Local reference for the timeout.
  notificationTimeout = null

  class NotificationView extends View
    template: 'notification'
    tagName: 'li'
    className: 'alert alert-success alert-dismissable'
    optionNames: @::optionNames.concat [
      'undoSelector', 'fadeSpeed', 'reqTimeout'
    ]
    undoSelector: '.undo'
    fadeSpeed: 500
    reqTimeout: 4000

    initialize: ->
      super
      @navigateDismiss()

    # Override to customize the undo element.
    getUndoElement: ->
      templates['notification-undo'] {
        label: I18n?.t('notifications.undo') or 'Undo'
      }

    # if `opts` has `navigateDismiss` then upon navigation the notification is
    # dismissed
    navigateDismiss: ->
      opts = @model.get('opts') or {}
      if opts.navigateDismiss
        @subscribeEvent 'dispatcher:dispatch', -> @dismiss()

    # Discard model when the view is removed.
    # `success` callback will execute when view is faded in `fadespeed` ms.
    #
    # Override to specify different behavior when the notification is closed.
    dismiss: ->
      @$el?.animate {opacity: 0}, @fadeSpeed, =>
        # The view can be disposed before the animation completes.
        @model.dispose() unless @disposed

    # Display undo and start the timeout for the view and optional
    # `success` callback.
    render: ->
      super

      opts = @model.get('opts') or {}
      # Limit undo to current change.
      if opts.undo
        # Only one action may be undone at any given time.
        $(@undoSelector).remove()
        opts.link = @getUndoElement()

      @$el.append opts.link if opts.link

      opts.deferred?.done => @dismiss()

      unless opts.sticky
        # Allow instance to specify timeout.
        timeout = opts.reqTimeout or @reqTimeout
        # Expose timeout for cancellation elsewhere.
        @model.timeout = notificationTimeout = window.setTimeout =>
          opts.success?()
          @dismiss()
        , timeout

    # Hooks up actions on the notification.
    attach: ->
      super

      @delegate 'click', '.close', (e) ->
        e.preventDefault()
        e.stopPropagation()
        @dismiss()

      # Commit to request when model is disposed.
      opts = @model.get('opts') or {}
      if opts.model
        @listenTo opts.model, 'dispose', ->
          window.clearTimeout notificationTimeout
          opts.success?()
          @dismiss()

      # This will overwrite other click handlers given in opts.
      if opts.undo
        opts.click =
          selector: @undoSelector
          handler: (e) ->
            e.preventDefault()
            window.clearTimeout notificationTimeout
            opts.undo()
            @dismiss()

      # You can pass in a selector and handler for a click event
      @delegate 'click', opts.click.selector, opts.click.handler if opts.click

      # Add specified classes on an instance basis.
      classes = opts.classes or 'alert-success'
      @$el.addClass classes
