define (require) ->
  Chaplin = require 'chaplin'
  StringTemplatable = require 'mixins/views/string-templatable'
  Filtering = require 'mixins/views/filtering'

  class FilterSelectionMock extends Chaplin.Collection
    fromObject: ->
      @trigger 'update'
      @trigger 'reset'
    toObject: ->
      x: 'z'

  class ViewMock extends Filtering StringTemplatable Chaplin.View
    autoRender: yes
    template: 'filtering-test'
    filterSelection: FilterSelectionMock
    getBrowserQuery: ->
    setBrowserQuery: ->

  describe 'Filtering', ->
    sandbox = null
    view = null
    filterGroups = null
    browserQuery = null
    withSyncDeep = null

    beforeEach ->
      sandbox = sinon.sandbox.create()
      sandbox.spy FilterSelectionMock::, 'fromObject'
      sandbox.spy FilterSelectionMock::, 'toObject'
      filterGroups = new Chaplin.Collection [{id: 'a'}, {id: 'b'}]
      if withSyncDeep
        filterGroups.isSyncedDeep = -> false
      sandbox.stub ViewMock::, 'getBrowserQuery', -> browserQuery or a: 'b'
      sandbox.stub ViewMock::, 'setBrowserQuery'
      view = new ViewMock {filterGroups}

    afterEach ->
      sandbox.restore()
      view.dispose()
      filterGroups.dispose()

    it 'should initialize filter view', ->
      filterView = view.subview 'filtering-control'
      expect(filterView.collection).to.be.instanceOf FilterSelectionMock
      expect(filterView.groupSource).to.equal filterGroups

    it 'should render filter view', ->
      expect(view.$ '.filter-input').to.exist

    expectResetSelection = (query) ->
      it 'should update filterSelection', ->
        expect(view.filterSelection.fromObject).to.have.been.calledWith \
          query?() or a: 'b', filterGroups

      it 'should not set browser query', ->
        expect(view.setBrowserQuery).to.have.not.been.called

    context 'without filterGroups.isSyncedDeep', ->
      expectResetSelection()

    context 'with filterGroups.isSyncedDeep', ->
      before ->
        withSyncDeep = true

      after ->
        withSyncDeep = false

      it 'should not update filterSelection', ->
        expect(view.filterSelection.fromObject).to.have.not.been.called

      context 'on syncDeep triggered', ->
        beforeEach ->
          filterGroups.trigger 'syncDeep'

        expectResetSelection()

    context 'on browser query change', ->
      filterngIsntActive = null

      before ->
        browserQuery = c: 'd'

      after ->
        browserQuery = null

      beforeEach ->
        if filterngIsntActive
          delete view.filterGroups
          view.filterSelection.fromObject.reset()
        view.onBrowserQueryChange()

      expectResetSelection -> browserQuery

      context 'when filtering is not active', ->
        before ->
          filterngIsntActive = true

        after ->
          filterngIsntActive = null

        it 'should not update filterSelection', ->
          expect(view.filterSelection.fromObject).to.have.not.been.called

    context 'on filter selection', ->
      event = null

      beforeEach ->
        view.filterSelection.trigger event

      expectQuery = ->
        it 'should set browser query', ->
          expect(view.setBrowserQuery).to.have.been.calledWith \
            x: 'z', a: undefined, b: undefined, page: 1

      context 'update event', ->
        before ->
          event = 'update'

        expectQuery()

      context 'update event', ->
        before ->
          event = 'reset'

        expectQuery()
