define (require) ->
  successHandler = (opts) ->
    @publishEvent 'notify', opts.saveMessage,
      model: opts.model
      success: ->
        opts.model.save opts.attribute, opts.value,
          patch: opts.patch
          # The model should already have been validated by the editable mixin.
          validate: no
      undo: =>
        opts.$field.text opts.original
        opts.$field.attr 'href', opts.href if opts.href
        @makeEditable opts

  ->
    @delayedSave = successHandler
    this
