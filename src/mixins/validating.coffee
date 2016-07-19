define (require) ->
  backboneValidation = require 'backbone_validation'
  stickit = require 'stickit'

  stickit.addHandler {
    selector: '*'
    setOptions:
      # force validation of a new value upon setting it to model
      validate: true
      # force updating model with a new value even
      # if there is a validation error
      # This is to make sure that UI state and model state are synced
      forceUpdate: true
  }

  backboneValidation.configure {
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
  }

  ###*
   * Turn on validation for view UI upon model attributes update.
   * Add/remove bootstrap validation classes for elements with errors.
   * @param  {Backbone.View} superclass
  ###
  (superclass) -> class Validating extends superclass
    ###*
     * Regex patterns that may be used in template data to
     * fill DOM elements pattern property.
     * @type {Object}
    ###
    patterns: backboneValidation.patterns

    initialize: ->
      super
      @bindModel @model if @model

    getTemplateData: ->
      _.extend super, regex: _.mapValues @patterns, (re) -> re.source

    dispose: ->
      @unbindModel @model if @model
      super

    bindModel: (model) ->
      if model.associatedViews
        if model.associatedViews.indexOf(this) < 0
          model.associatedViews.push this
      else
        model.associatedViews = [this]

    unbindModel: (model) ->
      if model.associatedViews
        model.associatedViews = _.without model.associatedViews, this
