import Chaplin from 'chaplin'
import StateBindable from './state-bindable'
import Templatable from './templatable'
import ActiveSyncMachine from '../models/active-sync-machine'
import Changable from '../models/changable'
import templateMock from './state-bindable.spec.hbs'

class ModelMock extends ActiveSyncMachine Changable Chaplin.Model

class ViewMock extends StateBindable Templatable Chaplin.View
  autoRender: yes
  template: templateMock

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
    model = new ModelMock()
    model.beginSync() if syncing
    ViewMock::initialState = state if state
    ViewMock::stateBindings = bindings if bindings
    view = new ViewMock {model}

  afterEach ->
    view.dispose()
    model.dispose()

  expectations = ->
    it 'should set button disabled', ->
      expect(view.$ '#button').to.be.disabled()

    context 'on state attr change', ->
      beforeEach ->
        view.state.set 'isDisabled', no

      it 'should set button enabled', ->
        expect(view.$ '#button').to.be.enabled()

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

  context 'hasChanges', ->
    it 'should initialize undefined hasChanges', ->
      expect(view.state.get 'hasChanges').to.be.undefined

    context 'on model change', ->
      beforeEach ->
        model.set a: 'b'

      it 'should should not have changes', ->
        expect(view.state.get 'hasChanges').to.be.true

      context 'on model synced', ->
        beforeEach ->
          model.trigger 'sync', model
          model.trigger 'synced', model

        it 'should should not have changes', ->
          expect(view.state.get 'hasChanges').to.be.false

  context 'without model or collection', ->
    anotherView = null

    beforeEach ->
      anotherView = new ViewMock()

    it 'should initialize with undefined syncState', ->
      expect(anotherView.state.get 'syncState').to.be.undefined
