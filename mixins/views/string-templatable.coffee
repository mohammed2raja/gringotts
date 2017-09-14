define (require) ->
  helper = require '../../lib/mixin-helper'

  # This mixin grants the ability for views to specify a string
  # as their template property.
  #
  # It assumes that there is a `views/templates` module object
  # with the string as keys and templates as values.
  (superclass) -> helper.apply superclass, (superclass) -> \

  class StringTemplatable extends superclass
    helper.setTypeName @prototype, 'StringTemplatable'

    optionNames: @::optionNames?.concat ['template']

    initialize: ->
      helper.assertViewOrCollectionView this
      super

    # Precompiled templates function initializer.
    getTemplateFunction: ->
      if @template
        if template = require('templates')[@template]
          template
        else
          throw new Error "The template file #{@template} doesn't exist."
