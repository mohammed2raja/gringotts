define (require) ->
  helper = require '../../lib/mixin-helper'

  (superclass) -> helper.apply superclass, (superclass) -> \

  class Content extends superclass
    helper.setTypeName @prototype, 'Content'

    container: '#content'
    containerMethod: 'prepend'

    initialize: ->
      helper.assertViewOrCollectionView this
      super
