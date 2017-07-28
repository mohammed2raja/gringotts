_ = require 'lodash'

###*
  * Returns hash of arguments as object. Useful for {{url (object a=b c=d)}}
  * @param  {Object} opts... Input hash
  * @return {Object}         Object from arguments
###
module.exports = (opts...) ->
  _.last(opts).hash
