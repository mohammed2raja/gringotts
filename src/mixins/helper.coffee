define (require) ->
  Chaplin = require 'chaplin'

  assertModel: (_this) ->
    unless _this instanceof Chaplin.Model
      throw new Error 'This mixin can be applied only to models.'

  assertCollection: (_this) ->
    unless _this instanceof Chaplin.Collection
      throw new Error 'This mixin can be applied only to collections.'

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
