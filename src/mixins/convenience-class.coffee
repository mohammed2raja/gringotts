define (require) ->
  utils = require '../lib/utils'

  ###*
   * Adds on a convenience class for QE purposes.
   * Based on the template property.
  ###
  _addConvenienceClass = ->
    @className = utils.convenienceClass @className, @template

  ->
    @before '_ensureElement', _addConvenienceClass
    this
