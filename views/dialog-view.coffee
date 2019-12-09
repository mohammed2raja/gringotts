import ModalView from './base/modal-view'
import template from './dialog'

export default class DialogView extends ModalView
  className: 'dialog'
  template: template
  title: null
  text: null
  cancelBtnLabel: I18n?.t('buttons.cancel') or 'Cancel'
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
    _.extend super(), {@title, @text, @buttons, @cancelBtnLabel}
