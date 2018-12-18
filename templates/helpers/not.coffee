export default (opts...) ->
  args = _.initial opts
  {fn, inverse} = _.last(opts) or {}
  if _.isEmpty _.compact args
    if fn then fn this else true
  else if inverse then inverse this else false
