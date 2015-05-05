define (require) ->
  ext = require 'ext/jquery'
  utils = require 'lib/utils'

  describe 'jQuery ext', ->
    describe 'setupError', ->
      beforeEach ->
        @reload = sinon.spy()
        sinon.spy utils, 'parseJSON'
        # Fake window-like object
        ext.setupError location: {@reload}

      afterEach ->
        $(document).off 'ajaxError'
        utils.parseJSON.restore()
        delete @reload

      it 'attaches something to the document', ->
        expect($._data(document).events).to.exist
          .and.to.have.property 'ajaxError'

      describe 'after an ajax error', ->
        beforeEach ->
          @server = sinon.fakeServer.create()
          $.ajax '/bloop'
          @server.respondWith @response
          @server.respond()

        afterEach ->
          @server.restore()

        describe 'with expired session', ->
          before ->
            @response = [401, {}, '{"CODE": "SESSION_EXPIRED"}']

          after ->
            delete @response

          it 'reloads the window', ->
            expect(@reload).to.have.been.calledOnce

        describe 'with a normal failure', ->
          before ->
            @response = [500, {}, '{}']

          after ->
            delete @response

          it 'does nothing', ->
            expect(@reload).to.not.have.been.called

          it 'does not parse the response', ->
            expect(utils.parseJSON).to.not.have.been.called
