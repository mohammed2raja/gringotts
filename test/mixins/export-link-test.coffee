define (require) ->
  Chaplin = require 'chaplin'
  utils = require '../../lib/utils'
  ExportLink = require 'mixins/export-link'

  class MockView extends ExportLink Chaplin.View

  describe 'ExportLink', ->
    view = null
    state = null

    beforeEach ->
      view = new MockView()
      view.collection =
        getState: -> _.extend {sort_by:'swag'}, state
        url: (url, state) -> "#{url}?#{utils.querystring.stringify(state)}"

    it 'should generate export link', ->
      expect(view.exportLink 'nasty/url').to.equal 'nasty/url?sort_by=swag'

    context 'with pagination', ->
      beforeEach ->
        state = {page:5, per_page:500}

      it 'should exclude pagination params', ->
        expect(view.exportLink 'nasty/url').to.equal 'nasty/url?sort_by=swag'
