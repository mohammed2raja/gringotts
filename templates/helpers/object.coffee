###*
  * Returns hash of arguments as object. Useful for {{url (object a=b c=d)}}
  * @param  {Object} opts... Input hash
  * @return {Object}         Object from arguments
###
export default (opts...) ->
  _.last(opts).hash
