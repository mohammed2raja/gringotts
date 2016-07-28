define (require) ->
  utils = require 'lib/utils'
  Chaplin = require 'chaplin'
  Routing = require 'mixins/views/routing'

  class MockView extends Routing Chaplin.View

  class MockCollectionView extends Routing Chaplin.CollectionView
    itemView: Chaplin.View

  describe 'Routing', ->
    sandbox = null
    view = null

    context 'view', ->
      beforeEach ->
        view = new MockView {
          routeName: 'that-route'
          routeParams: 'those-params'
          routeState: {}
        }

      afterEach ->
        view.dispose()

      it 'should set properties', ->
        expect(view.routeName).to.equal 'that-route'
        expect(view.routeParams).to.equal 'those-params'
        expect(view.routeState).to.eql {}

      it 'should return properties in template data', ->
        data = view.getTemplateData()
        expect(data.routeName).to.equal 'that-route'
        expect(data.routeParams).to.equal 'those-params'

      it 'should return route options', ->
        options = view.routeOpts()
        expect(options).to.eql {
          routeName: 'that-route'
          routeParams: 'those-params'
          routeState: {}
        }

      it 'should return extended route options', ->
        options = view.routeOptsWith a: 1
        expect(options).to.eql {
          a: 1
          routeName: 'that-route'
          routeParams: 'those-params'
          routeState: {}
        }

    context 'collection view', ->
      collection = null

      beforeEach ->
        sandbox = sinon.sandbox.create()
        sandbox.stub Chaplin.View::, 'getTemplateFunction'
        collection = new Chaplin.Collection [1, 2, 3]
        view = new MockCollectionView {
          collection
          routeName: 'that-route'
          routeParams: 'those-params'
          routeState: {}
        }

      afterEach ->
        sandbox.restore()
        collection.dispose()
        view.dispose()

      it 'should set properties to child views', ->
        childView = _.first view.subviews
        expect(childView.routeName).to.equal 'that-route'
        expect(childView.routeParams).to.equal 'those-params'
        expect(childView.routeState).to.eql {}

    context 'browser state', ->
      beforeEach ->
        view = new MockView {
          routeName: 'that-route'
          routeParams: 'those-params'
          routeState: getState: (state) -> _.extend {a: 1, b: 2}, state
        }

        afterEach ->
          view.dispose()

      it 'should return state', ->
        state = view.getBrowserState()
        expect(state).to.eql a: 1, b: 2

      context 'on set', ->
        beforeEach ->
          sandbox.stub utils, 'redirectTo'
          view.setBrowserState c: 3

        it 'should call redirectTo', ->
          expect(utils.redirectTo).to.have.been.calledWith 'that-route',
            'those-params', query: a: 1, b: 2, c: 3

    context 'collection view with proxy state', ->
      collection = null

      beforeEach ->
        sandbox = sinon.sandbox.create()
        sandbox.stub Chaplin.View::, 'getTemplateFunction'
        collection = new Chaplin.Collection [1, 2, 3]
        collection.proxyState = -> getState: -> a: 1
        view = new MockCollectionView {
          collection
          routeName: 'that-route'
          routeParams: 'those-params'
        }

      afterEach ->
        sandbox.restore()
        collection.dispose()
        view.dispose()

      it 'should take proxyState from collection', ->
        expect(view.routeState.getState()).to.eql a: 1
