define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'
  Paginated = require 'mixins/models/paginated'
  Paginating = require 'mixins/views/paginating'
  StringTemplatable = require 'mixins/views/string-templatable'

  class MockItemView extends Chaplin.View
    tagName: 'tr'
    className: 'test-item'
    getTemplateFunction: -> -> '<td><td><td>'

  class MockPaginatedCollection extends utils.mix Chaplin.Collection
      .with Paginated, ActiveSyncMachine
    DEFAULTS: _.extend {}, @::DEFAULTS, per_page: 10
    urlRoot: '/test'
    syncKey: 'itemsList'

  class MockPaginatingView extends utils.mix(Chaplin.CollectionView)
      .with StringTemplatable, Paginating
    loadingSelector: '.loading'
    itemView: MockItemView
    listSelector: 'tbody'
    template: 'paginating-test'
    templatePath: 'test/templates'

  describe 'Paginating mixin', ->
    sandbox = null
    collection = null
    view = null
    infinite = false

    beforeEach ->
      sandbox = sinon.sandbox.create useFakeServer: true
      sandbox.stub utils, 'reverse', (path, params, query) ->
        "#{path}?#{utils.querystring.stringify query}"
      collection = new MockPaginatedCollection()
      collection.infinite = infinite
      view = new MockPaginatingView {routeName: 'test', collection}
      collection.setState {}
      collection.fetch()
      sandbox.server.respondWith [200, {}, JSON.stringify({
        next_page_id: 'abcdef'
        count: 101
        itemsList: ({} for i in [0..101])
      })]
      sandbox.server.respond()

    afterEach ->
      sandbox.restore()
      collection.dispose()
      view.dispose()

    it 'should be instantiated', ->
      expect(view).to.be.an.instanceOf MockPaginatingView

    it 'should render pagination controls', ->
      expect(view.$ '.pagination-controls').to.exist.and
        .to.have.class "#{view.cid}"

    it 'should render links correctly', ->
      $link_prev = view.$ '.pagination-controls a.prev-page'
      $link_next = view.$ '.pagination-controls a.next-page'
      expect($link_prev).to.have.class('disabled-arrow').and.to.have
        .attr 'href', 'test?'
      expect($link_next).to.not.have.class 'disabled-arrow'
      expect($link_next).to.have.attr 'href', 'test?page=2'

    it 'should render range string', ->
      expect(view.$ '.pagination-controls strong').to.have.text '1-10 of 101'

    context 'changing to next page', ->
      beforeEach ->
        collection.setState page: 3
        collection.fetch()
        sandbox.server.respond()

      it 'should render links correctly', ->
        $link_prev = view.$ '.pagination-controls a.prev-page'
        $link_next = view.$ '.pagination-controls a.next-page'
        expect($link_prev).to.not.have.class 'disabled-arrow'
        expect($link_prev).to.have.attr 'href', 'test?page=2'
        expect($link_next).to.not.have.class 'disabled-arrow'
        expect($link_next).to.have.attr 'href', 'test?page=4'

      it 'should render range string', ->
        expect(view.$ '.pagination-controls strong').to.have.text '21-30 of 101'

    context 'changing to last page', ->
      beforeEach ->
        collection.setState page: 11
        collection.fetch()
        sandbox.server.respond()

      it 'should render links correctly', ->
        $link_prev = view.$ '.pagination-controls a.prev-page'
        $link_next = view.$ '.pagination-controls a.next-page'
        expect($link_prev).to.not.have.class 'disabled-arrow'
        expect($link_prev).to.have.attr 'href', 'test?page=10'
        expect($link_next).to.have.class 'disabled-arrow'
        expect($link_next).to.have.attr 'href', 'test?page=11'

      it 'should render range string', ->
        expect(view.$ '.pagination-controls strong').to.have
          .text '101-101 of 101'

    context 'infinite pagination', ->
      before ->
        infinite = true

      after ->
        infinite = false

      it 'should render links correctly', ->
        $link_prev = view.$ '.pagination-controls a.prev-page'
        $link_next = view.$ '.pagination-controls a.next-page'
        expect($link_prev).to.have.class 'disabled-arrow'
        expect($link_prev).to.have.attr 'href', 'test?'
        expect($link_next).to.not.have.class 'disabled-arrow'
        expect($link_next).to.have.attr 'href', 'test?page=abcdef'

      it 'should render range string', ->
        expect(view.$ '.pagination-controls strong').to.have.text ''

    context 'loading indicator start syncing', ->
      beforeEach ->
        collection.beginSync()

      it 'should show loading', ->
        expect(view.$loading).to.have.css 'display', 'table-row'

      it 'should hide all items', ->
        expect(view.$ '.test-item').to.have.css 'display', 'none'

      context 'and then finished', ->
        beforeEach ->
          collection.finishSync()

        it 'should hide loading', ->
          expect(view.$loading).to.have.css 'display', 'none'

        it 'should hide all items', ->
          expect(view.$ '.test-item').to.have.css 'display', 'table-row'
