define (require) ->
  Chaplin = require 'chaplin'
  StateBindable = require 'mixins/views/state-bindable'
  StringTemplatable = require 'mixins/views/string-templatable'

  class ViewMock extends StateBindable StringTemplatable Chaplin.View
    autoRender: yes
    template: 'state-bindable-test'
    templatePath: 'test/templates'

  initialState = isDisabled: yes

  stateBindings =
    '#button':
      attributes: [
        name: 'disabled'
        observe: 'isDisabled'
      ]

  describe 'StateBindable', ->
    view = null

    expectations = ->
      it 'should set button disabled', ->
        expect(view.$ '#button').to.have.attr 'disabled'

      context 'on state attr change', ->
        beforeEach ->
          view.state.set 'isDisabled', no

        it 'should set button enabled', ->
          expect(view.$ '#button').to.not.have.attr 'disabled'

      context 'on view dispose', ->
        beforeEach ->
          view.dispose()

        it 'should dispose state model', ->
          expect(view.state.disposed).to.be.true

    context 'configs set directly', ->
      beforeEach ->
        ViewMock::initialState = initialState
        ViewMock::stateBindings = stateBindings
        view = new ViewMock()

      afterEach ->
        view.dispose()

      expectations()

    context 'configs set though function', ->
      beforeEach ->
        ViewMock::initialState = -> initialState
        ViewMock::stateBindings = -> stateBindings
        view = new ViewMock()

      afterEach ->
        view.dispose()

      expectations()
