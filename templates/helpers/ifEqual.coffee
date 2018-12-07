import {getHandlebarsFuncs} from '../../lib/utils'

###*
  * Compares two values and renders matching template like #if
###
export default (lvalue, rvalue, options) ->
  if arguments.length < 2
    throw new Error('Handlebars Helper equal needs 2 parameters')
  {fn, inverse} = getHandlebarsFuncs [options or {}]
  if lvalue is rvalue
    if fn then fn this else true
  else if inverse then inverse this else false
