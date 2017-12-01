helper = require '../../lib/mixin-helper'

module.exports = (superclass) -> helper.apply superclass, (superclass) -> \

class Content extends superclass
  helper.setTypeName @prototype, 'Content'

  container: '#content'

  initialize: ->
    helper.assertViewOrCollectionView this
    super
