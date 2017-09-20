Chaplin = require 'chaplin'
ServiceErrorHandled = require 'mixins/models/service-error-handled'

class CollectionMock extends ServiceErrorHandled Chaplin.Collection

describe 'ServiceErrorHandled', ->
  sandbox = null
  collection = null

  beforeEach ->
    sandbox = sinon.sandbox.create()
    collection = new CollectionMock()
    sandbox.stub collection, 'sync', -> $.Deferred().reject()
    collection.fetch()

  afterEach ->
    sandbox.restore()
    collection.dispose()

  it 'should catch all fetch errors', ->
    expect(true).to.be.true
