define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  StringTemplatable = require '../../mixins/views/string-templatable'
  ServiceErrorReady = require '../../mixins/views/service-error-ready'

  class CollectionView extends utils.mix Chaplin.CollectionView
      .with StringTemplatable, ServiceErrorReady
    loadingSelector: '.loading'
    fallbackSelector: '.empty'
    useCssAnimation: yes
    animationStartClass: 'fade'
    animationEndClass: 'in'

    modelsFrom: (rows) ->
      rows = if rows.length then rows else [rows]
      itemViews = _.values @getItemViews()
      models = _.filter(itemViews, (v) -> v.el in rows).map (v) -> v.model

    rowsFrom: (models) ->
      models = if models.length then models else [models]
      itemViews = _.values @getItemViews()
      rows = _.filter(itemViews, (v) -> v.model in models).map (v) -> v.el
