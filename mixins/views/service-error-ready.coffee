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
    'unsynced collection': -> @toggleServiceError 'show'
    'syncing collection': -> @toggleServiceError 'hide'
    'synced collection': -> @toggleServiceError 'hide'

  initialize: ->
    helper.assertViewOrCollectionView this
    super arguments...

  render: ->
    super()
    @toggleServiceError 'hide'

  handleAny: ($xhr) ->
    if @toggleServiceError 'show'
      @markAsHandled $xhr
    else
      super $xhr

  toggleServiceError: (action) ->
    # do not show service error row if collection has rows already
    # this is the case when other syncing activity is going on using
    # the same collection instance (custom actions or bulk updates).
    return if @disposed or action is 'show' and @collection?.length
    @$(@errorSelector)[action]()
