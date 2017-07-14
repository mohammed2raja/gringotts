define (require) ->
  Chaplin = require 'chaplin'
  StringTemplatable = require 'mixins/views/string-templatable'

  class ViewMock extends StringTemplatable Chaplin.View
    template: 'string-templatable-test'

  describe 'StringTemplatable', ->
    view = null
    template = null

    beforeEach ->
      view = new ViewMock()
      template = view.getTemplateFunction()

    afterEach ->
      view.dispose()

    it 'returns the template function', ->
      expect(template()).to.include '<h1>Foo</h1>'

    describe 'with bad path', ->
      beforeEach ->
        view.template = 'a-non-existent-template'

      it 'throws an error', ->
        try
          view.getTemplateFunction()
        catch error
          message = error.message

        expect(message).to.contain 'a-non-existent-template'
