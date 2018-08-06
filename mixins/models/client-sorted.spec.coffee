import Chaplin from 'chaplin'
import ClientSorted from './client-sorted'

class MockClientSorted extends ClientSorted Chaplin.Collection
  secondSortOrder: -> 'asc'
  secondSortAttr: -> 'type'

dataset = [
  {name: 'foo', type: 'exploit'}
  {name: 'foo', type: 'adware'}
  {name: 'zardoz', type: 'mitm_attack'}
  {name: 'baz', type: 'backdoor'}
  {name: 'baz', type: 'riskware'}
]

describe 'ClientSorted mixin', ->
  collection = null
  models = null

  beforeEach ->
    policies = models || dataset
    collection = new MockClientSorted policies
    collection.query = {
      order: 'asc'
      sort_by: 'name'
    }

  afterEach ->
    collection.dispose()

  it 'should sort based on sort_by and secondarily by', ->
    collection.add name: 'abbeynormal', type: 'spam'
    expect(_.map(collection.models, (model) ->
      _.pick model.attributes, 'name', 'type'
    )).to.eql [
      {name: 'abbeynormal', type: 'spam'}
      {name: 'baz', type: 'backdoor'}
      {name: 'baz', type: 'riskware'}
      {name: 'foo', type: 'adware'}
      {name: 'foo', type: 'exploit'}
      {name: 'zardoz', type: 'mitm_attack'}
    ]

  it 'should change sort order if collection.query.order is set', ->
    collection.query.order = 'desc'
    collection.add name: 'boblablah', type: 'spam'
    expect(_.map(collection.models, (model) ->
      _.pick model.attributes, 'name', 'type'
    )).to.eql [
      {name: 'zardoz', type: 'mitm_attack'}
      {name: 'foo', type: 'adware'}
      {name: 'foo', type: 'exploit'}
      {name: 'boblablah', type: 'spam'}
      {name: 'baz', type: 'backdoor'}
      {name: 'baz', type: 'riskware'}
    ]

  context 'models without type attr', ->
    before ->
      models = [
        {name: 'foo'}
        {name: 'zardoz'}
        {name: 'baz'}
      ]

    after ->
      models = null

    it 'should sort based on sort_by', ->
      collection.add name: 'boblablah'
      expect(_.map(collection.models, 'attributes.name'))
        .to.eql [
          'baz'
          'boblablah'
          'foo'
          'zardoz'
        ]

  context 'sorting generic array', ->
    sorted = null

    beforeEach ->
      sorted = _.clone(dataset).sort _.bind collection.comparator, collection

    it 'should sort based on sort_by and sort secondarily by', ->
      expect(sorted).to.eql [
        {name: 'baz', type: 'backdoor'}
        {name: 'baz', type: 'riskware'}
        {name: 'foo', type: 'adware'}
        {name: 'foo', type: 'exploit'}
        {name: 'zardoz', type: 'mitm_attack'}
      ]
