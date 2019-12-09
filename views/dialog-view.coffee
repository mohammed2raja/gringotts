import ModalView from './base/modal-view'
import template from './dialog'

export default class DialogView extends ModalView
  className: 'dialog'
  template: template
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
    _.extend super(), {@title, @text, buttons: @buttons.concat([{
      className: 'btn-link'
      dataDismiss: 'modal'
      ariaLabel: 'Close'
      text: I18n?.t('buttons.cancel') or 'Cancel',
    }])}
