import {getHandlebarsFuncs} from '../../lib/utils'

###*
  * Helper which accepts two or more booleans and returns
  * template block executions.
###
export default (opts...) ->
  {fn, inverse, args} = getHandlebarsFuncs opts
  if _.isEmpty _.compact args
    if inverse then inverse this else false
  else if fn then fn this else true
