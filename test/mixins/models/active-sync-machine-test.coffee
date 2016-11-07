define (require) ->
  Chaplin = require 'chaplin'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'

  class MockCollection extends ActiveSyncMachine Chaplin.Collection

  describe 'ActiveSyncMachine', ->
    collection = null

    expectSyncMachineReactToModel = (targetFunc, sourceFunc) ->
      context 'on request', ->
        target = null
        source = null

        beforeEach ->
          target = targetFunc()
          source = sourceFunc()
          source.trigger 'request', source

        it 'should start the sync', ->
          expect(target.beginSync).to.be.calledOnce

        context 'on response', ->
          beforeEach ->
            source.trigger 'sync', source

          it 'should complete the sync with finishSync', ->
            expect(target.finishSync).to.be.calledOnce

        context 'on error', ->
          beforeEach ->
            source.trigger 'error', source

          it 'should complete the sync with unsync', ->
            expect(target.unsync).to.be.calledOnce

    expectSyncMachineReactToSyncMachine = (targetFunc, sourceFunc) ->
      context 'on beginSync', ->
        target = null
        source = null

        beforeEach ->
          target = targetFunc()
          source = sourceFunc()
          source.beginSync()

        it 'should start the sync', ->
          expect(target.beginSync).to.be.calledOnce

        context 'on finishSync', ->
          beforeEach ->
            source.finishSync()

          it 'should complete the sync with finishSync', ->
            expect(target.finishSync).to.be.calledOnce

          context 'on unsync', ->
            beforeEach ->
              source.unsync()

            it 'should complete the sync with unsync', ->
              expect(target.unsync).to.be.calledOnce

    beforeEach ->
      collection = new MockCollection()
      sinon.spy collection, 'beginSync'
      sinon.spy collection, 'finishSync'
      sinon.spy collection, 'unsync'

    expectSyncMachineReactToModel (-> collection), (-> collection)

    context 'binded to a source model', ->
      model = null

      beforeEach ->
        model = new Chaplin.Model()
        collection.bindSyncMachineTo model

      expectSyncMachineReactToModel (-> collection), (-> model)

      context 'and then unbinded', ->
        beforeEach ->
          collection.unbindSyncMachineFrom model

        context 'on request', ->
          beforeEach ->
            model.trigger 'request', model

          it 'should not start the sync', ->
            expect(collection.beginSync).to.not.be.calledOnce

    context 'linked to another SyncMachine', ->
      another = null

      beforeEach ->
        another = new MockCollection()
        collection.linkSyncMachineTo another

      expectSyncMachineReactToSyncMachine (-> collection), (-> another)

      context 'and then unlinked', ->
        beforeEach ->
          collection.unlinkSyncMachineFrom another

        context 'on beginSync', ->
          beforeEach ->
            another.beginSync()

          it 'should not start the sync', ->
            expect(collection.beginSync).to.not.be.calledOnce

    context 'linked to another SyncMachine that is already in some state', ->
      another = null

      beforeEach ->
        another = new MockCollection()
        another.beginSync()
        collection.linkSyncMachineTo another

      it 'should start the sync', ->
        expect(collection.beginSync).to.be.calledOnce
