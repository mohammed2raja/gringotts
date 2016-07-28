define (require) ->
  Chaplin = require 'chaplin'
  Classy = require 'mixins/views/classy'

  class MockView extends Classy Chaplin.View
    classyName: 'sweety'
    getTemplateFunction: -> -> ''

  describe 'Classy', ->
    view = null
    className = null
    complexClass = null

    beforeEach ->
      MockView::className = className if className
      MockView::classyName = complexClass if complexClass
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

      context 'with legit class name', ->
        before ->
          className = 'serious-sweety'

        after ->
          className = null

        it 'should have only nice class names', ->
          expect(view.$el).to.have.attr 'class', 'serious-sweety sweety'

        context 'with complex class', ->
          before ->
            complexClass = 'saulty-spicy sour-sweety'

          after ->
            complexClass = null

          it 'should have only classy names', ->
            expect(view.$el).to.have.attr 'class',
              'serious-sweety saulty-spicy sour-sweety'
