define (require) ->
  Classy = require '../../mixins/classy'
  View = require './view'

  ###*
   * View for bootstrap modals
  ###
  class ModalView extends Classy View
    optionNames: @::optionNames.concat ['forceOneInstance']
    classyName: 'modal fade'
    attributes:
      tabindex: -1
      role: 'dialog'

    _hide: ->
      @$el?.modal 'hide'

    _dispose: ->
      @_hide()
      # dispose responsibility is on model's holder
      return @dispose() unless @model or @collection

    attach: (opts) ->
      super
      if !!@forceOneInstance and @template? and $(".#{@template}").length
        return @_dispose()

      $body = $ 'body'
      # Globally prevent scrolling of page when modal is displayed.
      @$el.on 'shown.bs.modal', ->
        $body.addClass 'no-scroll'
      @$el.on 'hidden.bs.modal', =>
        $body.removeClass 'no-scroll'
        @_dispose()
      @$el.modal opts

    dispose: ->
      @_hide()
      super
