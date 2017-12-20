import helper from '../../lib/mixin-helper'
import ErrorHandling from './error-handling'

# Display errors when a collection sync returns an error.
# This follows a similar pattern to the `loadingSelector`
# and `fallbackSelector` that `Chaplin.CollectionView` provides.
export default (superclass) -> helper.apply superclass, (superclass) -> \

class ServiceErrorReady extends ErrorHandling superclass
  helper.setTypeName @prototype, 'ServiceErrorReady'

  errorSelector: '.service-error'
  listen:
    'unsynced collection': ->
      @$(@errorSelector).show() unless @disposed
    'syncing collection': ->
      @$(@errorSelector).hide() unless @disposed
    'synced collection': ->
      @$(@errorSelector).hide() unless @disposed

  initialize: ->
    helper.assertViewOrCollectionView this
    super arguments...

  render: ->
    super()
    @$(@errorSelector).hide()

  handleAny: ($xhr) ->
    @$(@errorSelector).show() unless @disposed
    @markAsHandled $xhr
