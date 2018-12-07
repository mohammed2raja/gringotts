import {getHandlebarsFuncs} from '../../lib/utils'

export default (opts...) ->
  {fn, inverse, args} = getHandlebarsFuncs opts
  if _.every args
    if fn then fn this else true
  else if inverse then inverse this else false
