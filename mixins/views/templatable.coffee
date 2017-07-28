helper = require '../../lib/mixin-helper'

module.exports = (superclass) -> helper.apply superclass, (superclass) -> \

class Templatable extends superclass
  helper.setTypeName @prototype, 'Templatable'

  optionNames: @::optionNames?.concat ['template']

  initialize: ->
    helper.assertViewOrCollectionView this
    super

  getTemplateFunction: ->
    if @template
      if _.isFunction(@template)
        @template
      else
        throw new Error 'The template property must be a function.'
