define (require) ->
  helper = require '../../lib/mixin-helper'

  # This mixin grants the ability for views to specify a string
  # as their template property.
  #
  # It assumes that there is a `views/templates` module object
  # with the string as keys and templates as values.
  #
  # You can override the template path by passing in `templatePath`
  # in the options.
  (superclass) -> class StringTemplatable extends superclass
    helper.setTypeName @prototype, 'StringTemplatable'

    optionNames: @::optionNames?.concat ['template']
    templatePath: 'templates'

    initialize: ->
      helper.assertViewOrCollectionView this
      super

    # Precompiled templates function initializer.
    getTemplateFunction: ->
      if @template
        if template = require(@templatePath)[@template]
          template
        else
          throw new Error "The template file #{@templatePath}/#{@template}
            doesn't exist."
