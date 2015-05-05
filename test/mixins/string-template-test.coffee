define (require) ->
  Chaplin = require 'chaplin'
  stringTemplate = require 'mixins/string-template'

  describe 'String template mixin', ->
    beforeEach ->
      @view = new Chaplin.View()
      stringTemplate.call @view, templatePath: 'backbone'
      @view.template = 'VERSION'
      sinon.spy @view, 'getTemplateFunction'
      @template = @view.getTemplateFunction()

    afterEach ->
      @view.dispose()

    it 'returns the template', ->
      expect(@template).to.equal Backbone.VERSION

    it 'defaults to standard path', ->
      stringTemplate.call @view
      try
        @view.getTemplateFunction()
      catch error
        message = error.message

      expect(message).to.contain 'views/templates'

    describe 'with bad path', ->
      beforeEach ->
        @view.template = 'a'

      it 'throws an error', ->
        try
          @view.getTemplateFunction()
        catch error
          message = error.message

        expect(message).to.contain 'backbone/a'
