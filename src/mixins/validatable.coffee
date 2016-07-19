define (require) ->
  moment = require 'moment'
  backboneValidation = require 'backbone_validation'

  backboneValidation.configure {
    labelFormatter: 'label'
  }

  # Override/extend default validation patterns
  _.extend backboneValidation.patterns,
    name: /^((?!<\\?.*>).)+/
    email: /^[^@]+@[^@]+\.[^@]+$/
    url: /[a-z0-9.\-]+\.[a-zA-Z]{2,}/
    guid: ///^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}
      -[89ab][0-9a-f]{3}-[0-9a-f]{12}$///

  _.extend backboneValidation.messages,
    name: '{0} must be a valid name'
    guid: '{0} must be a valid guid'
    date: '{0} must be a valid date'

  if I18n?
    for key in _.keys backboneValidation.messages
      backboneValidation.messages[key] = I18n.t "error.validation.#{key}"

  # Expected date format from browser input[type=date] elements
  BROWSER_DATE = ['MM/DD/YYYY', 'YYYY-MM-DD']

  ###*
   * Applies backbone.validation mixin to a Model.
   * Adds a validateDate function.
   * @param  {Backbone.Model} superclass
  ###
  (superclass) -> class Validatable extends superclass
    _.extend @prototype, _.extend {}, backboneValidation.mixin,
      # HACK force model validation if no args passed
      isValid: (option) ->
        backboneValidation.mixin.isValid.apply this, [option || true]
      # HACK until https://github.com/thedersen/backbone.validation/issues/232
      validate: ->
        error = backboneValidation.mixin.validate.apply this, arguments
        @validationError = error || null
        error

    validateDate: (value, attr) ->
      if value and not moment(value, BROWSER_DATE).isValid()
        backboneValidation.messages.date.replace '{0}',
          backboneValidation.labelFormatters.label attr, this
