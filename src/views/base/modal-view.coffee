define (require) ->
  View = require './view'

  ###*
   * View for bootstrap modals
   * @constructor
  ###
  class ModalView extends View
    optionNames: View::optionNames.concat ['forceOneInstance']

    className: 'modal'
    attributes:
      tabindex: -1
      role: 'dialog'

    attach: (opts) ->
      super
      if !!@forceOneInstance and @template? and $(".#{@template}").length
        @dispose()
        return
      $body = $ 'body'
      # Globally prevent scrolling of page when modal is displayed.
      @$el.on 'shown.bs.modal', ->
        $body.addClass 'no-scroll'
      @$el.on 'hidden.bs.modal', =>
        $body.removeClass 'no-scroll'
        @dispose()
      @$el.modal opts

    dispose: ->
      @$el?.modal 'hide'
      super
