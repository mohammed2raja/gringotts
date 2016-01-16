# This mixin adds genericSave handler method that could be used in combine
# with editable mixin to handle save actions from editable UI input controls.
#
# Pass delayedSave true in options to turn on couple of secs delay before
# saving update value on server. The notification with Undo will be shown.
define (require) ->
  _revertChanges = (opts) ->
    opts.$field?.text opts.original
    opts.$field?.attr 'href', opts.href if opts.href
    @makeEditable? opts

  genericSave = (opts) ->
    # The model should already have been validated
    # by the editable mixin.
    opts = _.extend {}, opts, validate: no
    if opts.delayedSave
      @publishEvent 'notify', opts.saveMessage,
        _.extend {}, opts,
          success: ->
            opts.model.save opts.attribute, opts.value,
              _.extend {}, opts,
                error: =>
                  _revertChanges.call this, opts
          undo: =>
            _revertChanges.call this, opts
    else
      opts.model.save opts.attribute, opts.value,
        _.extend {}, opts,
          success: =>
            @publishEvent 'notify', opts.saveMessage
          error: =>
            _revertChanges.call this, opts

  ->
    @genericSave = genericSave
    this
