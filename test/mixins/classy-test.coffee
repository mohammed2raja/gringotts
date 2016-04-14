define (require) ->
  Chaplin = require 'chaplin'
  Classy = require 'mixins/classy'

  class MockView extends Classy Chaplin.View
    classyName: 'sweety'
    getTemplateFunction: -> -> ''

  describe 'Classy', ->
    view = null

    beforeEach ->
      view = new MockView()
      view.render()

    afterEach ->
      view.dispose()

    it 'should add classy name', ->
      expect(view.$el).to.have.attr 'class', 'sweety'

    context 'on second render', ->
      beforeEach ->
        view.render()

      it 'should have only one classy name', ->
        expect(view.$el).to.have.attr 'class', 'sweety'
