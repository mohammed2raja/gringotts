# This mixin grants the ability for views to specify a string
# as their template property.
#
# It assumes that there is a `views/templates` module object
# with the string as keys and templates as values.
#
# You can override the template path by passing in `templatePath`
# in the options.
define (require) ->

  # Precompiled templates function initializer.
  getTemplateFunction: ->
    if @template
      tObj = require(@templatePath)[@template]
      if tObj
        tObj
      else
        errStr = "The template file #{@templatePath}/#{@template}
          doesn't exist."
        throw new Error errStr

  templatePath: 'templates'
