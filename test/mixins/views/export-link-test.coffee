define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  ExportLink = require 'mixins/views/export-link'

  class CollectionViewMock extends ExportLink Chaplin.CollectionView

  describe 'ExportLink', ->
    view = null
    query = null

    beforeEach ->
      view = new CollectionViewMock {
        collection:
          models: []
          getQuery: -> _.extend {sort_by: 'swag'}, query
          url: (url, query) -> "#{url}?#{utils.querystring.stringify query}"
      }

    it 'should generate export link', ->
      expect(view.exportLink 'nasty/url').to.equal 'nasty/url?sort_by=swag'

    context 'with pagination', ->
      beforeEach ->
        query = page: 5, per_page: 500

      it 'should exclude pagination params', ->
        expect(view.exportLink 'nasty/url').to.equal 'nasty/url?sort_by=swag'
