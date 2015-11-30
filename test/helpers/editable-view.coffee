define (require) ->
  Chaplin = require 'chaplin'
  editable = require 'mixins/editable'
  delayedSave = require 'mixins/delayed-save'

  class FakeView extends Chaplin.View
    mixin.call @prototype for mixin in [editable, delayedSave]
    autoRender: yes
    getTemplateFunction: ->
      (data) -> """
        <div>
          <span class="name-field" data-edit="name">#{data.name}</span>
          <span class="edit-name">Click to Edit</span>
          <a class="email-field" data-edit="email" href="mailto:#{data.email}">
            #{data.email}
          </a>
          <span class="edit-email">Click to Edit</span>
          <a class="url-field" data-edit="url" href="#{data.url}">
            #{data.url}
          </a>
          <span class="edit-url">Click to Edit</span>
        </div>
      """
    $field: ->
      @$ '.name-field'
