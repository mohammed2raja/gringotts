define (require) ->
  Chaplin = require 'chaplin'
  Routing = require 'mixins/routing'

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
        }

      it 'should set properties', ->
        expect(view.routeName).to.equal 'that-route'
        expect(view.routeParams).to.equal 'those-params'

      it 'should return properties in template data', ->
        data = view.getTemplateData()
        expect(data.routeName).to.equal 'that-route'
        expect(data.routeParams).to.equal 'those-params'

    context 'collection view', ->
      beforeEach ->
        sandbox = sinon.sandbox.create()
        sandbox.stub Chaplin.View::, 'getTemplateFunction'
        view = new MockCollectionView {
          collection: new Chaplin.Collection [1, 2, 3]
          routeName: 'that-route'
          routeParams: 'those-params'
        }

      afterEach ->
        sandbox.restore()

      it 'should set properties to child views', ->
        childView = _.first view.subviews
        expect(childView.routeName).to.equal 'that-route'
        expect(childView.routeParams).to.equal 'those-params'
