define (require) ->
  Backbone = require 'backbone'
  utils = require 'lib/utils'
  Chaplin = require 'chaplin'
  Routing = require 'mixins/views/routing'

  class MockView extends Routing Chaplin.View

  class MockCollectionView extends Routing Chaplin.CollectionView
    itemView: Chaplin.View

    onBrowserQueryChange: (query, diff) ->
      super
      @gotBrowserQuery = query
      @gotBrowserQueryDiff = diff

  describe 'Routing', ->
    sandbox = null
    view = null

    beforeEach ->
      sandbox = sinon.sandbox.create()
      sandbox.stub utils, 'redirectTo'

    afterEach ->
      sandbox.restore()

    context 'view', ->
      beforeEach ->
        view = new MockView {
          routeName: 'that-route'
          routeParams: 'those-params'
          routeQueryable: {}
        }

      afterEach ->
        view.dispose()

      it 'should set properties', ->
        expect(view.routeName).to.equal 'that-route'
        expect(view.routeParams).to.equal 'those-params'
        expect(view.routeQueryable).to.eql {}

      it 'should return properties in template data', ->
        data = view.getTemplateData()
        expect(data.routeName).to.equal 'that-route'
        expect(data.routeParams).to.equal 'those-params'

      it 'should return route options', ->
        options = view.routeOpts()
        expect(options).to.eql {
          routeName: 'that-route'
          routeParams: 'those-params'
          routeQueryable: {}
        }

      it 'should return extended route options', ->
        options = view.routeOptsWith a: 1
        expect(options).to.eql {
          a: 1
          routeName: 'that-route'
          routeParams: 'those-params'
          routeQueryable: {}
        }

    context 'collection view', ->
      collection = null

      beforeEach ->
        sandbox.stub Chaplin.View::, 'getTemplateFunction'
        collection = new Chaplin.Collection [1, 2, 3]
        view = new MockCollectionView {
          collection
          routeName: 'that-route'
          routeParams: 'those-params'
          routeQueryable: {}
        }

      afterEach ->
        collection.dispose()
        view.dispose()

      it 'should set properties to child views', ->
        childView = _.first view.subviews
        expect(childView.routeName).to.equal 'that-route'
        expect(childView.routeParams).to.equal 'those-params'
        expect(childView.routeQueryable).to.eql {}

    context 'browser query', ->
      routeQueryable = null

      beforeEach ->
        routeQueryable =
          getQuery: sinon.spy (query) -> _.extend {a: 1, b: 2}, query
          dispose: sinon.spy()
        view = new MockView {
          routeName: 'that-route'
          routeParams: 'those-params'
          routeQueryable
        }

      afterEach ->
        view.dispose()

      it 'should return query', ->
        query = view.getBrowserQuery()
        expect(query).to.eql a: 1, b: 2
        expect(view.routeQueryable.getQuery).to.be.calledWith {},
          inclDefaults: yes, usePrefix: no

      context 'on set', ->
        options = null

        beforeEach ->
          view.setBrowserQuery {c: 3}, options

        it 'should call redirectTo', ->
          expect(utils.redirectTo).to.have.been.calledWith 'that-route',
            'those-params', query: a: 1, b: 2, c: 3

        context 'with options', ->
          before ->
            options = foo: 'some'

          after ->
            options = null

          it 'should call redirectTo with options', ->
            expect(utils.redirectTo).to.have.been
              .calledWith 'that-route', 'those-params',
                query: {a: 1, b: 2, c: 3}, foo: 'some'

    context 'collection view with proxy queryable', ->
      collection = null
      proxy = null

      beforeEach ->
        sandbox.stub Chaplin.View::, 'getTemplateFunction'
        collection = new Chaplin.Collection [1, 2, 3]
        proxy = getQuery: -> a: 1, b: 2
        _.extend proxy, Backbone.Events
        collection.proxyQueryable = -> proxy
        view = new MockCollectionView {
          collection
          routeName: 'that-route'
          routeParams: 'those-params'
        }

      afterEach ->
        collection.dispose()
        view.dispose()

      it 'should take query from collection', ->
        expect(view.routeQueryable.getQuery()).to.eql a: 1, b: 2

      context 'on proxy queryChange', ->
        beforeEach ->
          proxy.trigger 'queryChange',
            query: x: 1, y: 2
            diff: ['a', 'b', 'x', 'y']

        it 'should call virtual method onBrowserQueryChange', ->
          expect(view.gotBrowserQuery).to.eql x: 1, y: 2
          expect(view.gotBrowserQueryDiff).to.eql ['a', 'b', 'x', 'y']

      context 'on browser query set', ->
        beforeEach ->
          view.setBrowserQuery c: 3 # assuming that own sets mute 'queryChange'
          proxy.trigger 'queryChange', query: q: 1, w: 2

        it 'should not call virtual method onBrowserQueryChange', ->
          expect(view.gotBrowserQuery).to.be.undefined
          expect(view.gotBrowserQueryDiff).to.be.undefined
