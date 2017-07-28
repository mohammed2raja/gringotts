module.exports = {
  stubModal: (sandbox, ctx) ->
    sandbox.stub $.fn, 'modal', (cmd) ->
      if cmd is undefined
        @addClass('in').trigger if ctx().transition then 'show.bs.modal'
        else 'shown.bs.modal'
      if cmd is 'hide'
        @removeClass('in').trigger if ctx().transition then 'hide.bs.modal'
        else 'hidden.bs.modal'
}
