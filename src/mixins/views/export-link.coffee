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
     * have collection property. Collection should have getQuery() method.
     * @param  {String} baseUrl - to build export url
     * @return {String}
    ###
    exportLink: (baseUrl) ->
      query = _.clone @collection.getQuery inclDefaults: yes
      delete query.page
      delete query.per_page
      @collection.url baseUrl, query
