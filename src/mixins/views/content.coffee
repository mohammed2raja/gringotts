define (require) ->
  helper = require '../helper'

  (superclass) -> class Content extends superclass
    container: '#content'
    containerMethod: 'prepend'

    initialize: ->
      helper.assertViewOrCollectionView this
      super
