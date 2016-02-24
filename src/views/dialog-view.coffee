define (require) ->
  ModalView = require './base/modal-view'

  class DialogView extends ModalView
    template: 'dialog'
    title: null
    text: null
    buttons: [{text:'OK', className: 'btn-action'}]

    optionNames: ModalView::optionNames.concat [
      'title', 'text', 'buttons'
    ]

    events:
      'click button': (e) ->
        $el = $(e.currentTarget)
        @buttons.forEach (b) =>
          if b.click and $el.hasClass b.className
            b.click.apply this, e

    getTemplateData: ->
      _.extend super, {@title, @text, @buttons}
