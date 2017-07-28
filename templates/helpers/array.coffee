_ = require 'lodash'

###*
  * Returns list of arguments as array. Useful for {{url (array a b c)}}
  * @param  {Array} opts... Input arguments
  * @return {Array}         Array of arguments
###
module.exports = (opts...) ->
  _.initial opts
