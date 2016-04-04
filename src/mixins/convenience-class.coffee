define (require) ->
  utils = require '../lib/utils'

  (superclass) -> class ConvenienceClass extends superclass
    _ensureElement: ->
      @addConvenienceClass()
      super

    ###*
     * Adds on a convenience class for QE purposes.
     * Based on the template property.
    ###
    addConvenienceClass: ->
      @className = utils.convenienceClass @className, @template
