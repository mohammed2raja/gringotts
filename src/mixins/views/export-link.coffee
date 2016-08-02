define (require) ->
  helper = require '../../lib/mixin-helper'

  (superclass) -> class ExportLink extends superclass
    helper.setTypeName @prototype, 'ExportLink'

    initialize: ->
      helper.assertCollectionView this
      super

    ###*
     * Generates a link to export items from the collection bypassing pagination
     * parameters. The mixin should be applied to views that
     * have collection property. Collection should have getState() method.
     * @param  {String} baseUrl - to build export url
     * @return {String}
    ###
    exportLink: (baseUrl) ->
      state = _.clone @collection.getState {}, inclDefaults: yes
      delete state.page
      delete state.per_page
      @collection.url baseUrl, state
