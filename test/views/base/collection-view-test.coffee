define (require) ->
  utils = require 'lib/utils'
  StringTemplatable = require 'mixins/string-templatable'
  Collection = require 'models/base/collection'
  CollectionView = require 'views/base/collection-view'
  View = require 'views/base/view'

  class MockItemView extends View
    tagName: 'tr'
    className: 'test-item'
    getTemplateFunction: -> -> '<td><td><td>'

  class MockCollection extends Collection
    syncKey: 'tests'
    urlRoot: '/test'
    DEFAULTS: _.extend {}, @::DEFAULTS,
      sort_by: 'attrA'

  class MockCollectionView extends StringTemplatable CollectionView
    itemView: MockItemView
    template: 'table-test'
    templatePath: 'test/templates'
    listSelector: 'tbody'
    sortableTableHeaders:
      attrA: 'Attribute A'
      attrB: 'Attribute B'

  describe 'Collection view', ->
    view = null
    server = null
    collection = null
    viewConfig = {}
    data = [
      {attrA: 'Z', attrB: 'A', id: 0}
      {attrA: 'B', attrB: 'Z', id: 1}
      {attrA: 'A', attrB: 'Z', id: 2}
      {attrA: 'A', attrB: 'A', id: 3}
    ]

    beforeEach ->
      sinon.stub utils, 'reverse'
      server = sinon.fakeServer.create()
      collection = new MockCollection data
      view = new MockCollectionView _.extend {},
        {collection: collection, routeName: 'test'}, viewConfig
      collection.trigger 'sync', collection
      server.respond()

    afterEach ->
      server.restore()
      utils.reverse.restore()
      collection.dispose()
      view.dispose()

    it 'should render the correct baseUrl', ->
      expect(utils.reverse).to.be.calledWith 'test', null, {order: 'asc'}

    it 'should get sortInfo', ->
      expect(view._getSortInfo()).to.eql {
        attrA:
          attr: 'attrA'
          viewId: view.cid
          text: 'Attribute A'
          order: 'desc'
          nextState: order: 'asc'
          routeName: 'test'
          routeParams: undefined
        attrB:
          attr: 'attrB'
          viewId: view.cid
          text: 'Attribute B'
          order: ''
          nextState: order: 'asc', sort_by: 'attrB'
          routeName: 'test'
          routeParams: undefined
      }

    it 'should render headers correctly', ->
      expect(view.$ 'th[data-sort=attrA]').to.have.class('sorting-control')
        .and.to.have.class "#{view.cid}"
      expect(view.$ 'th[data-sort=attrA] a').to.have.class 'desc'
      expect(view.$ 'th[data-sort=attrA] span').to.have.text 'Attribute A'

    it 'should highlight the appropriate table data elements', ->
      expect(view.$ 'td:nth-child(1)').to.have.class 'highlighted'
      expect(view.$ 'td:nth-child(2)').to.not.have.class 'highlighted'

    context 'when altering the order state', ->
      beforeEach ->
        collection.setState {order: 'asc'}
        collection.trigger 'sync', collection
        server.respond()

      it 'should correctly determine the sortInfo', ->
        expect(view._getSortInfo()).to.eql {
          attrA:
            attr: 'attrA'
            viewId: view.cid
            text: 'Attribute A'
            order: 'asc'
            nextState: {}
            routeName: 'test'
            routeParams: undefined
          attrB:
            attr: 'attrB'
            viewId: view.cid
            text: 'Attribute B'
            order: ''
            nextState: order: 'asc', sort_by: 'attrB'
            routeName: 'test'
            routeParams: undefined
        }

    context 'when altering the sort_by state', ->
      beforeEach ->
        collection.setState {sort_by: 'attrB'}
        collection.trigger 'sync', collection
        server.respond()

      it 'should correctly determine the sortInfo', ->
        expect(view._getSortInfo()).to.eql {
          attrA:
            attr: 'attrA'
            viewId: view.cid
            text: 'Attribute A'
            order: ''
            nextState: order: 'asc'
            routeName: 'test'
            routeParams: undefined
          attrB:
            attr: 'attrB'
            viewId: view.cid
            text: 'Attribute B'
            order: 'desc'
            routeName: 'test'
            routeParams: undefined
            nextState:
              sort_by: 'attrB'
              order: 'asc'
        }

    context 'url overriding', ->
      beforeEach ->
        collection.setState {sort_by:'swag'}
        server.respond()

      it 'should override url with custom rootUrl', ->
        resultUrl = collection.url 'sneaky/url'
        expect(resultUrl.startsWith 'sneaky/url').to.be.true
        expect(resultUrl).to.have.string 'sort_by=swag'

      it 'should override url with custom state', ->
        expect(collection.url 'nasty/url', {filter_by:'dresscode'}).
          to.equal 'nasty/url?filter_by=dresscode'