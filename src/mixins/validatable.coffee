define (require) ->
  moment = require 'moment'
  backboneValidation = require 'backbone_validation'

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

  # Expected date format from browser input[type=date] elements
  BROWSER_DATE = ['MM/DD/YYYY', 'YYYY-MM-DD']

  ###*
   * Applies backbone.validation mixin to a Model.
   * Adds a validateDate function.
   * @param  {Backbone.Model} superclass
  ###
  (superclass) -> class Validatable extends superclass
    _.extend @prototype, backboneValidation.mixin

    validateDate: (value, attr) ->
      if value and not moment(value, BROWSER_DATE).isValid()
        backboneValidation.messages.date.replace '{0}',
          backboneValidation.labelFormatters.label attr, this
