define (require) ->
  Classy = require '../../mixins/views/classy'
  View = require './view'

  ###*
   * View for bootstrap modals
  ###
  class ModalView extends Classy View
    classyName: 'modal fade'
    attributes:
      role: 'dialog'
    events:
      # Globally prevent scrolling of page when modal is displayed.
      'shown.bs.modal': ->
        $('body').addClass 'no-scroll'
      'hidden.bs.modal': ->
        $('body').removeClass 'no-scroll'
        @hidden = true
        # dispose responsibility is on model's holder
        @dispose() if @disposeRequested or not (@model or @collection)

    attach: (opts) ->
      super
      @$el.modal opts

    hide: ->
      @$el.modal 'hide' if @$el and @$el.hasClass 'in'

    dispose: ->
      @hide()
      super if @hidden # wait untils BS animations over
      @disposeRequested = true
