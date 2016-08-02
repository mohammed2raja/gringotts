define (require) ->
  helper = require '../../lib/mixin-helper'

  (superclass) -> class Content extends superclass
    helper.setTypeName @prototype, 'Content'

    container: '#content'
    containerMethod: 'prepend'

    initialize: ->
      helper.assertViewOrCollectionView this
      super
