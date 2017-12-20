import helper from '../../lib/mixin-helper'

export default (superclass) -> helper.apply superclass, (superclass) -> \

class Content extends superclass
  helper.setTypeName @prototype, 'Content'

  container: '#content'

  initialize: ->
    helper.assertViewOrCollectionView this
    super arguments...
