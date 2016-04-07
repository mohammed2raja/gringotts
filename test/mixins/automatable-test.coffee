define (require) ->
  Chaplin = require 'chaplin'
  Automatable = require 'mixins/automatable'
  StringTemplatable = require 'mixins/string-template'

  class MockView extends StringTemplatable Automatable Chaplin.View
    template: 'foo/automatable-view'
    templatePath: 'test/templates'

  describe 'Automatable', ->
    view = null

    beforeEach ->
      view = new MockView()
      view.render()

    afterEach ->
      view.dispose()

    it 'should add convenience class', ->
      expect(view.$el).to.have.attr 'qe-id', 'foo-automatable-view'
