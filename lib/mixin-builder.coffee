define (require) ->
  mixinHelper = require './mixin-helper'

  ###*
   * A helper class that gets a list of mixins and creates
   * a chain of inheritance.
  ###
  class MixinBuilder
    ###*
     * @param  {Type} superclass A target class to mixin into.
    ###
    constructor: (@superclass) ->

    ###*
     * @param  {Array} ...  A collection of mixins.
     * @return {Type}       A result class with all mixins applied only once.
    ###
    with: ->
      _.reduce arguments, (type, mixin) -> mixinHelper.apply type, mixin,
      @superclass
