ModalView = require './base/modal-view'

module.exports = class DialogView extends ModalView
  className: 'dialog'
  template: require './dialog.hbs'
  title: null
  text: null
  buttons: [
    text: I18n?.t('buttons.OK') or 'OK',
    className: 'btn-primary confirm-button'
  ]
  optionNames: @::optionNames.concat [
    'title', 'text', 'buttons'
  ]
  events:
    'click button': (e) ->
      $el = $(e.currentTarget)
      @buttons.forEach (b) =>
        b.click.call this, e if b.click and $el.hasClass b.className

  getTemplateData: ->
    _.extend super(), {@title, @text, @buttons}
