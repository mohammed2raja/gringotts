define (require) ->
  exportLink = require 'mixins/export-link'
  utils = require '../../lib/utils'

  describe 'Export link mixin', ->
    obj = null
    state = null

    beforeEach ->
      obj =
        collection:
          getState: -> _.extend {sort_by:'swag'}, state
          url: (url, state) -> "#{url}?#{utils.querystring.stringify(state)}"
      _.extend obj, exportLink

    it 'should generate export link', ->
      expect(obj.exportLink 'nasty/url').to.equal 'nasty/url?sort_by=swag'

    context 'with pagination', ->
      beforeEach ->
        state = {page:5, per_page:500}

      it 'should exclude pagination params', ->
        expect(obj.exportLink 'nasty/url').to.equal 'nasty/url?sort_by=swag'
