define (require) ->
  Classy = require '../../mixins/views/classy'
  View = require './view'

  ###*
   * Base View for bootstrap modals.
   * The instance of this modal view should be always added into 'subviews' of
   * the parent host Chaplin.View that initiates modal creation.
   * This will guarantee that modal view is disposed when host view is disposed.
  ###
  class ModalView extends Classy View
    classyName: 'modal fade'
    attributes:
      role: 'dialog'
    events:
      'shown.bs.modal': -> @onShown()
      'hidden.bs.modal': -> @onHidden()

    attach: (opts) ->
      super
      @$el.modal opts

    show: ->
      return if @disposed
      @delegateEvents()
      @delegateListeners()
      @render()
      @attach()

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
      if @modalVisible
        @once 'hidden', -> super
        @hide()
      else
        super
