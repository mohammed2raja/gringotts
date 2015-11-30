# This mixin grants the ability for views to specify a string
# as their template property.
#
# It assumes that there is a `views/templates` module object
# with the string as keys and templates as values.
#
# You can override the template path by passing in `templatePath`
# in the options.
define (require) ->
  templatePath = ''

  # Precompiled templates function initializer.
  getTemplateFunction = ->
    template = @template
    if template
      tObj = require(templatePath)[template]
      if tObj
        tObj
      else
        errStr = "The template file #{templatePath}/#{template} doesn't exist."
        throw new Error errStr

  (opts={}) ->
    # Reset between multiple calls.
    templatePath = opts.templatePath or 'views/templates'

    @getTemplateFunction = getTemplateFunction
    this
