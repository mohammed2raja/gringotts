import Chaplin from 'chaplin'
import Templatable from '../../mixins/views/templatable'
import ServiceErrorReady from '../../mixins/views/service-error-ready'
import ErrorHandling from '../../mixins/views/error-handling'

export default class CollectionView extends Templatable ServiceErrorReady \
    ErrorHandling Chaplin.CollectionView
  loadingSelector: '.loading'
  fallbackSelector: '.empty'
  useCssAnimation: yes
  animationStartClass: 'fade'
  animationEndClass: 'in'

  # overrides default Chaplin method to unlock the ability of customizing
  # item views with extra set of options upon instantiation
  initItemView: (model, options) ->
    if @itemView
      new @itemView _.extend {autoRender: false, model}, options
    else
      throw new Error 'The CollectionView#itemView property ' +
        'must be defined or the initItemView() must be overridden.'

  modelsFrom: (rows) ->
    rows = if rows.length then rows else [rows]
    itemViews = _.values @getItemViews()
    models = _.filter(itemViews, (v) -> v.el in rows).map (v) -> v.model

  rowsFrom: (models) ->
    models = if models.length then models else [models]
    itemViews = _.values @getItemViews()
    rows = _.filter(itemViews, (v) -> v.model in models).map (v) -> v.el
