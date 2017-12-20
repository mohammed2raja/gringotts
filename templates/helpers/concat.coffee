import _ from 'lodash'

###*
  * A simple helper to concat strings.
  * @param {array} opts A list of string to be combined.
###
export default (opts...) ->
  result = _(opts).initial().reduce (result, part) ->
    result + part
  , ''
