define (require) ->
  Chaplin = require 'chaplin'

  assertModel: (target) ->
    unless target instanceof Chaplin.Model
      throw new Error 'This mixin can be applied only to models.'

  assertNotModel: (target) ->
    if target instanceof Chaplin.Model
      throw new Error 'This mixin can not be applied to models.'

  assertCollection: (target) ->
    unless target instanceof Chaplin.Collection
      throw new Error 'This mixin can be applied only to collections.'

  assertNotCollection: (target) ->
    if target instanceof Chaplin.Collection
      throw new Error 'This mixin can not be applied to collections.'

  assertModelOrCollection: (target) ->
    unless (target instanceof Chaplin.Model or
      target instanceof Chaplin.Collection)
        throw new Error 'This mixin can be applied only to
          models or collections.'

  assertView: (target) ->
    unless target instanceof Chaplin.View
      throw new Error 'This mixin can be applied only to views.'

  assertCollectionView: (target) ->
    unless target instanceof Chaplin.CollectionView
      throw new Error 'This mixin can be applied only to collection views.'

  assertViewOrCollectionView: (target) ->
    unless (target instanceof Chaplin.View or
      target instanceof Chaplin.CollectionView)
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
   * @param  {Function} mixin
   * @return {Boolean}
  ###
  withMixin: (something, mixin) ->
    mixinName = @getTypeName mixinProto = mixin(Object)::
    unless mixinName
      throw new Error "The mixin #{mixinProto.constructor.name}
      should have type name set. Call mixin-helper.setTypeName() on prototype."
    chain = Chaplin.utils.getPrototypeChain something
    if target = _.find(chain, (pro) => mixinName is @getTypeName pro)
      targetFunctions = _.functions something
      _.functions(mixinProto).every (func) -> _(targetFunctions).includes func
    else
      false

  ###*
   * Checks if an object has a specific mixin in the inheritance chain.
   * @param  {Object} obj
   * @param  {Function} mixin
   * @return {Boolean}
  ###
  instanceWithMixin: (obj, mixin) ->
    @withMixin obj, mixin

  ###*
   * Checks if a class has a specific mixin in the inheritance chain.
   * @param  {Type} type
   * @param  {Function} mixin
   * @return {Boolean}
  ###
  typeWithMixin: (type, mixin) ->
    @withMixin type::, mixin

  ###*
   * Applies a mixin to a class if the class doesn't have it
   * in the inheritance chain yet.
   * @param  {Type} type
   * @param  {Function} mixin
   * @return {Type}
  ###
  apply: (type, mixin) ->
    if @typeWithMixin type, mixin then type else mixin type
