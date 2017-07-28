utils = require 'lib/utils'
helper = require '../../lib/mixin-helper'
ErrorHandling = require './error-handling'

# This mixin adds genericSave handler method that could be used in combine
# with editable mixin to handle save actions from editable UI input controls.
#
# Pass delayedSave true in options to turn on couple of secs delay before
# saving update value on server. The notification with Undo will be shown.
module.exports = (superclass) -> helper.apply superclass, (superclass) -> \

class GenericSave extends ErrorHandling superclass
  helper.setTypeName @prototype, 'GenericSave'

  initialize: ->
    helper.assertViewOrCollectionView this
    super

  genericSave: (opts) ->
    # The model should already have been validated
    # by the editable mixin.
    opts = _.extend {}, _.omit(opts, ['success']),
      wait: yes, validate: no
    if opts.delayedSave
      @publishEvent 'notify', opts.saveMessage,
        _.extend {}, opts,
          success: =>
            opts.model.save opts.attribute, opts.value, opts
              .catch ($xhr) => @genericSaveRevert opts, $xhr
              .catch @handleError
          undo: =>
            @genericSaveRevert opts
    else
      opts.model.save opts.attribute, opts.value, opts
        .then => @publishEvent 'notify', opts.saveMessage
        .catch ($xhr) => @genericSaveRevert opts, $xhr
        .catch @handleError

  genericSaveRevert: (opts, $xhr) ->
    opts.$field?.text opts.original
    opts.$field?.attr 'href', opts.href if opts.href
    @makeEditable? opts unless $xhr
    if $xhr
      if $xhr.status in [400, 406]
        if response = utils.parseJSON $xhr.responseText
          if message = response.error or response.errors?[opts.attribute]
            @notifyError message
            return
      $xhr
