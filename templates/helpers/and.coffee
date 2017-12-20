import utils from 'lib/utils'
import _ from 'lodash'

export default (opts...) ->
  {fn, inverse, args} = utils.getHandlebarsFuncs opts
  if _.every args
    if fn then fn this else true
  else if inverse then inverse this else false
