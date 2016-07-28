define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  Editable = require 'mixins/views/editable'
  GenericSave = require 'mixins/views/generic-save'

  class FakeView extends Editable GenericSave Chaplin.View
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
