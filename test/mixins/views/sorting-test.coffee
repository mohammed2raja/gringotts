define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  Sorted = require 'mixins/models/sorted'
  Sorting = require 'mixins/views/sorting'
  StringTemplatable = require 'mixins/views/string-templatable'

  class MockItemView extends Chaplin.View
    tagName: 'tr'
    className: 'test-item'
    getTemplateFunction: -> -> '<td><td><td>'

  class MockCollection extends Sorted Chaplin.Collection
    urlRoot: '/test'
    DEFAULTS: _.extend {}, @::DEFAULTS, sort_by: 'attr_a'

  class MockSortingView extends utils.mix(Chaplin.CollectionView)
      .with StringTemplatable, Sorting
    itemView: MockItemView
    template: 'sorting-test'
    templatePath: 'test/templates'
    listSelector: 'tbody'
    sortableTableHeaders:
      attr_a: 'Attribute A'
      attr_b: 'Attribute B'

  describe 'Sorting mixin', ->
    sandbox = null
    view = null
    collection = null

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: true
      sandbox.stub utils, 'reverse', (path, params, query) ->
        "#{path}?#{utils.querystring.stringify query}"
      collection = new MockCollection()
      view = new MockSortingView _.extend {routeName: 'test', collection}
      collection.setState {}
      sandbox.server.respondWith [200, {}, JSON.stringify [{}, {}, {}]]
      sandbox.server.respond()

    afterEach ->
      sandbox.restore()
      collection.dispose()
      view.dispose()

    it 'should render headers correctly', ->
      expect(view.$ 'th[data-sort=attr_a]').to.have.class('sorting-control')
        .and.to.have.class "#{view.cid}"
      expect(view.$ 'th[data-sort=attr_b]').to.have.class('sorting-control')
        .and.to.have.class "#{view.cid}"

    it 'should render headers labels', ->
      expect(view.$ 'th[data-sort=attr_a] span').to.have.text 'Attribute A'
      expect(view.$ 'th[data-sort=attr_b] span').to.have.text 'Attribute B'

    it 'should render links correctly', ->
      $link_a = view.$ 'th[data-sort=attr_a] a'
      $link_b = view.$ 'th[data-sort=attr_b] a'
      expect($link_a).to.have.class('desc').and.to.have
        .attr 'href', 'test?order=asc'
      expect($link_b).to.not.have.class 'desc'
      expect($link_b).to.have.attr 'href', 'test?order=asc&sort_by=attr_b'

    it 'should highlight sorted table row cells', ->
      expect(view.$ 'td:nth-child(1)').to.have.class 'highlighted'
      expect(view.$ 'td:nth-child(2)').to.not.have.class 'highlighted'

    context 'changing sorting order', ->
      beforeEach ->
        collection.setState order: 'asc', sort_by: 'attr_b'
        sandbox.server.respond()

      it 'should render links correctly', ->
        $link_a = view.$ 'th[data-sort=attr_a] a'
        $link_b = view.$ 'th[data-sort=attr_b] a'
        expect($link_a).to.not.have.class 'desc'
        expect($link_a).to.have.attr 'href', 'test?order=asc'
        expect($link_b).to.have.class('asc').and.to.have
          .attr 'href', 'test?sort_by=attr_b'
