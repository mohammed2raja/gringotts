define (require) ->
  # This mixin grants the ability for views to specify a string
  # as their template property.
  #
  # It assumes that there is a `views/templates` module object
  # with the string as keys and templates as values.
  #
  # You can override the template path by passing in `templatePath`
  # in the options.
  (superclass) -> class StringTemplatable extends superclass
    optionNames: @::optionNames.concat ['template']
    templatePath: 'templates'

    # Precompiled templates function initializer.
    getTemplateFunction: ->
      if @template
        if template = require(@templatePath)[@template]
          template
        else
          throw new Error "The template file #{@templatePath}/#{@template}
            doesn't exist."
