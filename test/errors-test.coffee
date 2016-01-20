define (require) ->
  ext = require 'errors'
  utils = require 'lib/utils'

  describe 'Errors', ->
    describe 'setupErrorHandling', ->
      beforeEach ->
        @reload = sinon.spy()
        @publishEvent = sinon.spy()
        sinon.spy utils, 'parseJSON'
        sinon.stub utils, 'redirectTo'
        ((window.I18n = {}).t = (text) -> text) if @i18n
        # Fake window-like object
        ext.setupErrorHandling
          location: {@reload}
          publishEvent: @publishEvent

      afterEach ->
        $(document).off 'ajaxError'
        utils.parseJSON.restore()
        utils.redirectTo.restore()
        delete window.I18n
        delete @reload
        delete @publishEvent

      it 'should attach something to the document', ->
        expect($._data(document).events).to.exist
          .and.to.have.property 'ajaxError'

      context 'after an ajax error', ->
        beforeEach ->
          $(document).trigger 'ajaxError', @xhr

        afterEach ->
          delete @xhr.errorHandled

        context 'with 401 (session expired)', ->
          before ->
            @xhr = status: 401, responseText: '{"CODE": "SESSION_EXPIRED"}'

          after ->
            delete @xhr

          it 'should reload the window', ->
            expect(@reload).to.have.been.calledOnce

        context 'with 403 (access denied)', ->
          before ->
            @xhr = status: 403

          after ->
            delete @xhr

          it 'should redirect to root route', ->
            expect(utils.redirectTo).to.have.been.calledWith {}

          it 'should send error notification', ->
            expect(@publishEvent).to.have.been.calledWith 'notify'

          it 'should handle response', ->
            expect(@xhr).to.have.property('errorHandled').and.equal true

          context 'and response JSON', ->
            before ->
              @xhr.responseText = '{"error": "No access available"}'
            after ->
              delete @xhr.responseText

            it 'should notify with message from response', ->
              expect(@publishEvent).to.have.been.
                calledWith 'notify', 'No access available'

          context 'with I18n', ->
            before ->
              @i18n = yes

            after ->
              delete @i18n

            it 'should notify with message from i18n', ->
              text = I18n.t 'error.no_access'
              expect(@publishEvent).to.have.been.calledWith 'notify', text

        context 'with a random failure', ->
          before ->
            @xhr = status: 500

          after ->
            delete @xhr

          it 'should send error notification', ->
            expect(@publishEvent).to.have.been.calledWith 'notify'

          it 'should handle response', ->
            expect(@xhr).to.have.property('errorHandled').and.equal true

          context 'and response JSON', ->
            before ->
              @xhr.responseText = '{"message": "Operation failed!"}'

            after ->
              delete @xhr.responseText

            it 'should notify with message from response', ->
              expect(@publishEvent).to.have.been.
                calledWith 'notify', 'Operation failed!'

          context 'with I18n', ->
            before ->
              @i18n = yes

            after ->
              delete @i18n

            it 'should notify with message from i18n', ->
              text = I18n.t 'error.notification'
              expect(@publishEvent).to.have.been.calledWith 'notify', text

          context 'and bad response JSON', ->
            before ->
              @xhr.responseText = '<html></html>'

            after ->
              delete @xhr.responseText

            it 'should notify with default message', ->
              expect(@publishEvent).to.have.been.calledWith 'notify',
                'There was a problem communicating with the server.'
