define (require) ->
  utils = require 'lib/utils'
  Errors = require 'lib/errors'

  describe 'Errors', ->
    describe 'setupErrorHandling', ->
      reload = null
      publishEvent = null
      i18n = null

      beforeEach ->
        reload = sinon.spy()
        publishEvent = sinon.spy()
        sinon.spy utils, 'parseJSON'
        sinon.stub utils, 'redirectTo'
        ((window.I18n = {}).t = (text) -> text) if i18n
        # Fake window-like object
        Errors.setupErrorHandling
          location: {reload}
          publishEvent: publishEvent

      afterEach ->
        $(document).off 'ajaxError'
        utils.parseJSON.restore()
        utils.redirectTo.restore()
        delete window.I18n
        reload = null
        publishEvent = null

      it 'should attach something to the document', ->
        expect($._data(document).events).to.exist
          .and.to.have.property 'ajaxError'

      context 'after an ajax error', ->
        xhr = null

        beforeEach ->
          $(document).trigger 'ajaxError', xhr

        afterEach ->
          xhr.errorHandled = null

        context 'with 401 (session expired)', ->
          before ->
            xhr = status: 401, responseText: '{"CODE": "SESSION_EXPIRED"}'

          after ->
            xhr = null

          it 'should reload the window', ->
            expect(reload).to.have.been.calledOnce

        context 'with 403 (access denied)', ->
          before ->
            xhr = status: 403

          after ->
            xhr = null

          it 'should redirect to root route', ->
            expect(utils.redirectTo).to.have.been.calledWith {}

          it 'should send error notification', ->
            expect(publishEvent).to.have.been.calledWith 'notify'

          it 'should handle response', ->
            expect(xhr).to.have.property('errorHandled').and.equal true

          context 'and response JSON', ->
            before ->
              xhr.responseText = '{"error": "No access available"}'
            after ->
              xhr.responseText = null

            it 'should notify with message from response', ->
              expect(publishEvent).to.have.been.
                calledWith 'notify', 'No access available'

          context 'with I18n', ->
            before ->
              i18n = yes

            after ->
              i18n = null

            it 'should notify with message from i18n', ->
              text = I18n.t 'error.no_access'
              expect(publishEvent).to.have.been.calledWith 'notify', text

        context 'with a random failure', ->
          before ->
            xhr = status: 500

          after ->
            xhr = null

          it 'should send error notification', ->
            expect(publishEvent).to.have.been.calledWith 'notify'

          it 'should handle response', ->
            expect(xhr).to.have.property('errorHandled').and.equal true

          context 'and response JSON', ->
            before ->
              xhr.responseText = '{"message": "Operation failed!"}'

            after ->
              xhr.responseText = null

            it 'should notify with message from response', ->
              expect(publishEvent).to.have.been.
                calledWith 'notify', 'Operation failed!'

          context 'with I18n', ->
            before ->
              i18n = yes

            after ->
              i18n = null

            it 'should notify with message from i18n', ->
              text = I18n.t 'error.notification'
              expect(publishEvent).to.have.been.calledWith 'notify', text

          context 'and bad response JSON', ->
            before ->
              xhr.responseText = '<html></html>'

            after ->
              xhr.responseText = null

            it 'should notify with default message', ->
              expect(publishEvent).to.have.been.calledWith 'notify',
                'There was a problem communicating with the server.'
