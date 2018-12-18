###*
  * Helper which accepts two or more booleans and returns
  * template block executions.
###
export default (opts...) ->
  args = _.initial opts
  {fn, inverse} = _.last(opts) or {}
  if _.isEmpty _.compact args
    if inverse then inverse this else false
  else if fn then fn this else true
