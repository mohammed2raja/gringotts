utils = require 'lib/utils'
_ = require 'lodash'

###*
  * Helper which accepts two or more booleans and returns
  * template block executions.
###
module.exports = (opts...) ->
  {fn, inverse, args} = utils.getHandlebarsFuncs opts
  if _.isEmpty _.compact args
    if inverse then inverse this else false
  else if fn then fn this else true
