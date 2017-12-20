import _ from 'lodash'

###*
  * Returns list of arguments as array. Useful for {{url (array a b c)}}
  * @param  {Array} opts... Input arguments
  * @return {Array}         Array of arguments
###
export default (opts...) ->
  _.initial opts
