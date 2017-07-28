_ = require 'lodash'

###*
  * A simple helper to concat strings.
  * @param {array} opts A list of string to be combined.
###
module.exports = (opts...) ->
  result = _(opts).initial().reduce (result, part) ->
    result + part
  , ''
