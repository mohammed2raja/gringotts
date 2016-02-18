define (require) ->
  View = require 'views/base/view'

  describe 'View', ->
    view = null
    template = null
    viewConfig = null

    beforeEach ->
      view = new View viewConfig or {}

    afterEach ->
      view.dispose()

    it 'initializes', ->
      expect(view).to.be.an.instanceOf View
