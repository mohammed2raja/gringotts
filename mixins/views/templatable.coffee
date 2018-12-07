import helper from '../../lib/mixin-helper'

export default (superclass) -> helper.apply superclass, (superclass) -> \

class Templatable extends superclass
  helper.setTypeName @prototype, 'Templatable'

  optionNames: @::optionNames?.concat ['template']

  initialize: ->
    helper.assertViewOrCollectionView this
    super arguments...

  getTemplateFunction: ->
    if @template
      if _.isFunction @template
        @template
      else
        throw new Error 'The template property must be a function.'


  dispose: ->
    delete @template
    super arguments...
