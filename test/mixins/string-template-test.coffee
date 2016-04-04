define (require) ->
  StringTemplate = require 'mixins/string-template'
  View = require 'views/base/view'

  class MockView extends StringTemplate View
    template: 'VERSION'
    templatePath: 'backbone'

  describe 'StringTemplate', ->
    view = null
    template = null

    beforeEach ->
      view = new MockView()
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
