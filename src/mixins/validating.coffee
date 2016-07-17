define (require) ->
  backboneValidation = require 'backbone_validation'
  stickit = require 'stickit'

  # force validation on all view-to-model bindings set
  stickit.addHandler {
    selector: '*'
    setOptions: validate: true
  }

  ###*
   * Turn on validation for view UI upon model attributes update.
   * Add/remove bootstrap validation classes for elements with errors.
   * @param  {Backbone.View} superclass
  ###
  (superclass) -> class Validating extends superclass
    patterns: backboneValidation.patterns
    validationConfig:
      forceUpdate: true

      valid: (view, attr, selector) ->
        $el = view.$ "[name=#{attr}]"
        $group = $el.closest '.form-group'
        .removeClass 'has-error'
        .find('.help-block').html('').addClass('hidden')

      invalid: (view, attr, error, selector) ->
        $el = view.$ "[name=#{attr}]"
        $group = $el.closest '.form-group'
        .addClass('has-error')
        .find('.help-block').html(error).removeClass('hidden')

    initialize: ->
      super
      backboneValidation.bind this, @validationConfig

    getTemplateData: ->
      _.extend super, regex: _.mapValues @patterns, (re) -> re.source
