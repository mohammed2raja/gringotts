define (require) ->
  Chaplin = require 'chaplin'

  assertModel: (_this) ->
    unless _this instanceof Chaplin.Model
      throw new Error 'This mixin can be applied only to models.'

  assertNotModel: (_this) ->
    if _this instanceof Chaplin.Model
      throw new Error 'This mixin can not be applied to models.'

  assertCollection: (_this) ->
    unless _this instanceof Chaplin.Collection
      throw new Error 'This mixin can be applied only to collections.'

  assertNotCollection: (_this) ->
    if _this instanceof Chaplin.Collection
      throw new Error 'This mixin can not be applied to collections.'

  assertModelOrCollection: (_this) ->
    unless (_this instanceof Chaplin.Model or
      _this instanceof Chaplin.Collection)
        throw new Error 'This mixin can be applied only to
          models or collections.'

  assertView: (_this) ->
    unless _this instanceof Chaplin.View
      throw new Error 'This mixin can be applied only to views.'

  assertCollectionView: (_this) ->
    unless _this instanceof Chaplin.CollectionView
      throw new Error 'This mixin can be applied only to collection views.'

  assertViewOrCollectionView: (_this) ->
    unless (_this instanceof Chaplin.View or
      _this instanceof Chaplin.CollectionView)
        throw new Error 'This mixin can be applied only to
          views or collection views.'

  ###*
   * Returns a secretly set mixin type name.
   * @param  {Object} prototype to ask for
   * @return {String}           a mixin type name
  ###
  getTypeName: (prototype) ->
    prototype.__mixinTypeName__

  ###*
   * Sets a secret property with type name of the mixin. We need it for
   * reflection capabilities in runtime. To figure if an instance of a class
   * has a certain mixin applied.
   * @param {Object} prototype to check
   * @param {String} name      of a mixin to check
  ###
  setTypeName: (prototype, name) ->
    prototype.__mixinTypeName__ = name

  ###*
   * Checks if an object or a prototype has mixin prototype in
   * the inheritance chain.
   * @param  {Object|Prototype} something
   * @param  {Prototype} mixinProto
   * @return {Boolean}
  ###
  withMixin: (something, mixinProto) ->
    mixinName = @getTypeName mixinProto
    unless mixinName
      throw new Error "The mixin #{mixinProto.constructor.name}
      should have type name set. Call mixin-helper.setTypeName() on prototype."
    chain = Chaplin.utils.getPrototypeChain something
    if target = _.find(chain, (pro) => mixinName is @getTypeName pro)
      targetFunctions = _.functions something
      _.functions(mixinProto).every (func) ->
        -1 < targetFunctions.indexOf func
    else
      false

  ###*
   * Checks if an object has a specific mixin in the inheritance chain.
   * @param  {Object} obj
   * @param  {Function} mixin
   * @return {Boolean}
  ###
  instanceWithMixin: (obj, mixin) ->
    @withMixin obj, mixin(Object)::

  ###*
   * Checks if an class has a specific mixin in the inheritance chain.
   * @param  {Class} _class
   * @param  {Function} mixin
   * @return {Boolean}
  ###
  classWithMixin: (_class, mixin) ->
    @withMixin _class::, mixin(Object)::
