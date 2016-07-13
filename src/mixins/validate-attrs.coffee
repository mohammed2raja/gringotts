define (require) ->
  # Default validation criterion
  blank = (text) ->
    message = I18n?.t('error.validation.value_required') or 'Value Required'
    message if not text or text.length is 0

  # Allow a model to specify the function name to use for validation.
  # The function will be invoked on the instance or default to a provided
  # blank method if it does not exist.
  #
  # The specified function should return a truthy value only
  # if there is a problem (per Backbone conventions).
  (superclass) -> class ValidateAttrs extends superclass
    # Map of attributes to validation method.
    validateAttrs: {}

    # Inlined to bind methods to the host object.
    validate: (attrs, options) ->
      foundError = no
      errors = _.reduce @validateAttrs, (memo, name, attr) =>
        method = @[name] or blank
        # Only validate attributes passed in (including ones with falsy values)
        # or validate everything required for a complete model validation
        # (options.validate=true is passed by backbone)
        if attrs.hasOwnProperty(attr) or method is blank and options?.validate
          modelErr = method.call this, attrs[attr]
        if modelErr
          foundError = yes
          memo[attr] = modelErr
        memo
      , {}
      # Return falsy value if there are no errors.
      errors if foundError
