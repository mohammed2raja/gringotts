define (require) ->
  Chaplin = require 'chaplin'
  StringTemplatable = require 'mixins/views/string-templatable'

  class ViewMock extends StringTemplatable Chaplin.View
    template: 'VERSION'
    templatePath: 'backbone'

  describe 'StringTemplatable', ->
    view = null
    template = null

    beforeEach ->
      view = new ViewMock()
      sinon.spy view, 'getTemplateFunction'
      template = view.getTemplateFunction()

    afterEach ->
      view.dispose()

    it 'returns the template', ->
      expect(template).to.equal Backbone.VERSION

    describe 'with bad path', ->
      beforeEach ->
        view.template = 'a'

      it 'throws an error', ->
        try
          view.getTemplateFunction()
        catch error
          message = error.message

        expect(message).to.contain 'backbone/a'
