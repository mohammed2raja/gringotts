utils = require 'lib/utils'
_ = require 'lodash'

module.exports = (opts...) ->
  {fn, inverse, args} = utils.getHandlebarsFuncs opts
  if _.isEmpty _.compact(args)
    if fn then fn this else true
  else if inverse then inverse this else false
