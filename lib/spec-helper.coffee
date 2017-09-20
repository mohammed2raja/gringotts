module.exports = {
  stubModal: (sandbox, ctx) ->
    sandbox.stub $.fn, 'modal', (cmd) ->
      context = ctx() if ctx
      if cmd is undefined
        event = if context?.transition \
          then 'show.bs.modal' else 'shown.bs.modal'
        @addClass('in').trigger event
      if cmd is 'hide'
        event = if context?.transition \
          then 'hide.bs.modal' else 'hidden.bs.modal'
        @removeClass('in').trigger event
}
