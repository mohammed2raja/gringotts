define (require) ->
  Chaplin = require 'chaplin'
  StateBindable = require 'mixins/views/state-bindable'
  StringTemplatable = require 'mixins/views/string-templatable'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'

  class SyncMachineModelMock extends ActiveSyncMachine Chaplin.Model

  class ViewMock extends StateBindable StringTemplatable Chaplin.View
    autoRender: yes
    template: 'state-bindable-test'

  initialState = isDisabled: yes

  stateBindings =
    '#button':
      attributes: [
        name: 'disabled'
        observe: 'isDisabled'
      ]

  describe 'StateBindable', ->
    view = null
    model = null
    syncing = null
    state = null
    bindings = null

    beforeEach ->
      model = new SyncMachineModelMock()
      model.beginSync() if syncing
      ViewMock::initialState = state if state
      ViewMock::stateBindings = bindings if bindings
      view = new ViewMock {model}

    afterEach ->
      view.dispose()
      model.dispose()

    expectations = ->
      it 'should set button disabled', ->
        expect(view.$ '#button').to.be.disabled

      context 'on state attr change', ->
        beforeEach ->
          view.state.set 'isDisabled', no

        it 'should set button enabled', ->
          expect(view.$ '#button').to.be.enabled

      context 'on view dispose', ->
        beforeEach ->
          view.dispose()

        it 'should dispose state model', ->
          expect(view.state.disposed).to.be.true

    context 'configs set directly', ->
      before ->
        state = _.clone initialState
        bindings = _.clone stateBindings

      after ->
        state = null
        bindings = null

      expectations()

    context 'configs set though function', ->
      before ->
        state = -> _.clone initialState
        bindings = -> _.clone stateBindings

      after ->
        state = null
        bindings = null

      expectations()

    context 'syncState', ->
      it 'should initialize default syncState', ->
        expect(view.state.get 'syncState').to.equal 'unsynced'

      context 'when model is syncing already', ->
        before ->
          syncing = true

        after ->
          syncing = null

        it 'should initialize syncState as syncing', ->
          expect(view.state.get 'syncState').to.equal 'syncing'

        context 'on finish sync', ->
          beforeEach ->
            model.finishSync()

          it 'should set syncState as synced', ->
            expect(view.state.get 'syncState').to.equal 'synced'
