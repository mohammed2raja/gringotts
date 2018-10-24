import Chaplin from 'chaplin'
import ClientSorted from './client-sorted'

class MockClientSorted extends ClientSorted Chaplin.Collection
  secondSortOrder: -> 'asc'
  secondSortAttr: ->  'type'
  thirdSortOrder: ->  'asc'
  thirdSortAttr: ->   'group'

dataset = [
  {name: 'foo',    type: 'exploit',     group: 1}
  {name: 'foo',    type: 'adware',      group: 2}
  {name: 'foo',    type: 'adware',      group: 1}
  {name: 'zardoz', type: 'mitm_attack', group: 1}
  {name: 'baz',    type: 'backdoor',    group: 1}
  {name: 'baz',    type: 'riskware',    group: 1}
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
    collection.add name: 'abbeynormal', type: 'spam', group: 1
    expect(_.map(collection.models, (model) ->
      _.pick model.attributes, 'name', 'type', 'group'
    )).to.eql [
      {name: 'abbeynormal', type: 'spam',        group: 1}
      {name: 'baz',         type: 'backdoor',    group: 1}
      {name: 'baz',         type: 'riskware',    group: 1}
      {name: 'foo',         type: 'adware',      group: 1}
      {name: 'foo',         type: 'adware',      group: 2}
      {name: 'foo',         type: 'exploit',     group: 1}
      {name: 'zardoz',      type: 'mitm_attack', group: 1}
    ]

  it 'should change sort order if collection.query.order is set', ->
    collection.query.order = 'desc'
    collection.add name: 'boblablah', type: 'spam', group: 1
    expect(_.map(collection.models, (model) ->
      _.pick model.attributes, 'name', 'type', 'group'
    )).to.eql [
      {name: 'zardoz',    type: 'mitm_attack', group: 1}
      {name: 'foo',       type: 'adware',      group: 1}
      {name: 'foo',       type: 'adware',      group: 2}
      {name: 'foo',       type: 'exploit',     group: 1}
      {name: 'boblablah', type: 'spam',        group: 1}
      {name: 'baz',       type: 'backdoor',    group: 1}
      {name: 'baz',       type: 'riskware',    group: 1}
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
        {name: 'baz',    type: 'backdoor',    group: 1}
        {name: 'baz',    type: 'riskware',    group: 1}
        {name: 'foo',    type: 'adware',      group: 1}
        {name: 'foo',    type: 'adware',      group: 2}
        {name: 'foo',    type: 'exploit',     group: 1}
        {name: 'zardoz', type: 'mitm_attack', group: 1}
      ]
