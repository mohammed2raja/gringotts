define (require) ->
  View = require 'views/base/view'

  describe 'View', ->
    view = null

    beforeEach ->
      view = new View()

    afterEach ->
      view.dispose()

    it 'should be initialized', ->
      expect(view).to.be.an.instanceOf View
