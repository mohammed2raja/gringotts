import Chaplin from 'chaplin'
import ActiveSyncMachine from './active-sync-machine'
import WithSubmodels from './with-submodels'

class SubModel extends ActiveSyncMachine Chaplin.Model
class SubCollection extends ActiveSyncMachine Chaplin.Collection

class ModelWithSubmodels extends WithSubmodels ActiveSyncMachine Chaplin.Model
  @SUB_MODELS = [
    'submodelA'
    'subcollectionA'
  ]
  SUB_MODELS: ModelWithSubmodels.SUB_MODELS

  initialize: ->
    super arguments...

  initSubmodels: ->
    @submodelA = new SubModel()
    @subcollectionA = new SubCollection()

describe 'WithSubmodels', ->
  model = null
  sandbox = null

  beforeEach ->
    sandbox = sinon.sandbox.create()
    model = new ModelWithSubmodels()

  afterEach ->
    model.dispose()
    sandbox.restore()

  it 'should set submodels', ->
    expect(model.submodels).to.eql([
      model.submodelA
      model.subcollectionA
    ])

  context 'submodels', ->
    beforeEach ->
      model.trigger 'change:submodelA', model, {'a': 1}

    it 'updates attributes of submodel', ->
      expect(model.submodelA.get('a')).to.eql 1

  context 'subcollections', ->
    beforeEach ->
      model.trigger 'change:subcollectionA', model, [1, 2, 3]

    it 'updates attributes of submodel', ->
      expect(model.subcollectionA.length).to.eql 3
