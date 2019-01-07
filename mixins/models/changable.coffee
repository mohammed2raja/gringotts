import Chaplin from 'chaplin'
import helper from '../../lib/mixin-helper'

###*
 * Tracks runtime changes of a Model or Collection.
###
export default (superclass) -> class Changable extends superclass
  initialize: (data, {parse = false} = {}) ->
    helper.assertModelOrCollection this
    super arguments...
    if this instanceof Chaplin.Collection
      json = if parse and not _.isEmpty data then @parse data else data
      @resetServerState json
    else
      # Backbone.Model does parsing and initial attrs setting by default
      @resetServerState()
    @on 'sync', -> @resetServerState()
    if @comparator
      @on 'sort', -> @serverState?.sort _.bind @comparator, this

  ###*
   * Returns true if there was any changes made after the last sync with server.
   * @return {Boolean}
  ###
  hasChanges: ->
    not _.isEqual @serverState, @toJSON()

  ###*
   * Force reset saved "server" state with current data state.
  ###
  resetServerState: (data) ->
    @serverState = if not _.isEmpty(data) then data else @toJSON()
