import Chaplin from 'chaplin'
import utils from 'lib/utils'
import ActiveSyncMachine from 'mixins/models/active-sync-machine'
import Paginated from 'mixins/models/paginated'
import Paginating from 'mixins/views/paginating'
import Templatable from 'mixins/views/templatable'

class ItemViewMock extends Chaplin.View
  tagName: 'tr'
  className: 'test-item'
  getTemplateFunction: -> -> '<td><td><td>'

class PaginatedCollectionMock extends Paginated ActiveSyncMachine \
    Chaplin.Collection
  DEFAULTS: _.extend {}, @::DEFAULTS, per_page: 10
  urlRoot: '/test'
  syncKey: 'itemsList'
  ignoreKeys: ['bad']

class PaginatingViewMock extends Templatable Paginating Chaplin.CollectionView
  loadingSelector: '.loading'
  itemView: ItemViewMock
  listSelector: 'tbody'
  template: require './paginating.spec.hbs'

describe 'Paginating mixin', ->
  sandbox = null
  collection = null
  view = null
  infinite = false

  beforeEach ->
    sandbox = sinon.sandbox.create useFakeServer: true
    sandbox.stub utils, 'reverse', (path, params, query) ->
      "#{path}?#{utils.querystring.stringify query}"
    collection = new PaginatedCollectionMock()
    collection.infinite = infinite
    view = new PaginatingViewMock {routeName: 'test', collection}
    collection.fetchWithQuery {bad: 'something'}
    sandbox.server.respondWith [200, {}, JSON.stringify {
      next_page_id: 'abcdef'
      count: 101
      itemsList: ({} for i in [0..101])
    }]
    sandbox.server.respond()

  afterEach ->
    sandbox.restore()
    collection.dispose()
    view.dispose()

  it 'should be instantiated', ->
    expect(view).to.be.an.instanceOf PaginatingViewMock

  it 'should render pagination controls', ->
    expect(view.$ '.pagination-controls').to.exist.and
      .to.have.class "#{view.cid}"

  it 'should render links correctly', ->
    $link_prev = view.$ '.pagination-controls a.prev-page'
    $link_next = view.$ '.pagination-controls a.next-page'
    expect($link_prev).to.have.attr 'disabled'
    expect($link_prev).to.have.attr 'href', 'test?'
    expect($link_next).to.not.have.attr 'disabled'
    expect($link_next).to.have.attr 'href', 'test?page=2'

  it 'should render range string', ->
    expect(view.$ '.pagination-range').to.have.text '1-10 of 101'

  context 'changing to next page', ->
    beforeEach ->
      collection.fetchWithQuery page: 3
      sandbox.server.respond()

    it 'should render links correctly', ->
      $link_prev = view.$ '.pagination-controls a.prev-page'
      $link_next = view.$ '.pagination-controls a.next-page'
      expect($link_prev).to.not.have.attr 'disabled'
      expect($link_prev).to.have.attr 'href', 'test?page=2'
      expect($link_next).to.not.have.attr 'disabled'
      expect($link_next).to.have.attr 'href', 'test?page=4'

    it 'should render range string', ->
      expect(view.$ '.pagination-range').to.have.text '21-30 of 101'

  context 'changing to last page', ->
    beforeEach ->
      collection.fetchWithQuery page: 11
      sandbox.server.respond()

    it 'should render links correctly', ->
      $link_prev = view.$ '.pagination-controls a.prev-page'
      $link_next = view.$ '.pagination-controls a.next-page'
      expect($link_prev).to.not.have.attr 'disabled'
      expect($link_prev).to.have.attr 'href', 'test?page=10'
      expect($link_next).to.have.attr 'disabled'
      expect($link_next).to.have.attr 'href', 'test?page=11'

    it 'should render range string', ->
      expect(view.$ '.pagination-range').to.have.text '101-101 of 101'

  context 'infinite pagination', ->
    before ->
      infinite = true

    after ->
      infinite = false

    it 'should render links correctly', ->
      $link_prev = view.$ '.pagination-controls a.prev-page'
      $link_next = view.$ '.pagination-controls a.next-page'
      expect($link_prev).to.have.attr 'disabled'
      expect($link_prev).to.have.attr 'href', 'test?'
      expect($link_next).to.not.have.attr 'disabled'
      expect($link_next).to.have.attr 'href', 'test?page=abcdef'

    it 'should render range string', ->
      expect(view.$ '.pagination-range').to.have.text ''

  context 'on fetching start', ->
    beforeEach (done) ->
      collection.fetchWithQuery page: 2
      done()

    it 'should show loading', ->
      expect(view.$loading).to.not.have.css 'display', 'none'

    it 'should remove all items', ->
      expect(view.$ '.test-item').to.not.exist

    context 'on fetch finish', ->
      beforeEach ->
        sandbox.server.respondWith [200, {}, JSON.stringify {
          count: 101
          itemsList: ({} for i in [0..10])
        }]
        sandbox.server.respond()

      it 'should hide loading', ->
        expect(view.$loading).to.have.css 'display', 'none'

      it 'should have new items', ->
        expect(view.$ '.test-item').to.exist
