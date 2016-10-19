define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  errors = require 'lib/errors'

  describe 'errors', ->
    sandbox = null

    beforeEach ->
      sandbox = sinon.sandbox.create()

    afterEach ->
      sandbox.restore()

    describe 'setupErrorHandling', ->
      publishEvent = null
      originalBroker = null
      i18n = null
      customHandler = null

      beforeEach ->
        sandbox.spy utils, 'parseJSON'
        sandbox.stub utils, 'redirectTo'
        sandbox.stub utils, 'getLocation', -> '/my/location/'
        sandbox.stub utils, 'setLocation'
        sandbox.stub utils, 'reloadLocation'
        publishEvent = sinon.spy()
        originalBroker = Chaplin.EventBroker
        Chaplin.EventBroker = {publishEvent}
        ((window.I18n = {}).t = (text) -> text) if i18n
        errors.setupErrorHandling customHandler

      afterEach ->
        $(document).off 'ajaxError'
        delete window.I18n
        Chaplin.EventBroker = originalBroker

      it 'should attach something to the document', ->
        expect($._data(document).events).to.exist
          .and.to.have.property 'ajaxError'

      context 'after an ajax error', ->
        status = null
        errorHandled = null
        responseText = null
        url = null
        xhr = null

        beforeEach ->
          xhr = {status, errorHandled, responseText}
          $(document).trigger 'ajaxError', [
            xhr
            url: url or 'http://example.com'
          ]

        context 'with 401 (session expired)', ->
          before ->
            status = 401
            errorHandled = true # even if it's handled

          after ->
            status = null
            errorHandled = null

          it 'should reload the window', ->
            expect(utils.reloadLocation).to.have.been.calledOnce

          context 'with redirect_url', ->
            before ->
              responseText = '{"redirect_url": "/foo"}'

            after ->
              responseText = null

            it 'should redirect to proper url', ->
              expect(utils.setLocation).to.have.been
                .calledWith 'http://example.com/foo?destination=/my/location/'

            context 'and relative request url', ->
              before ->
                url = '/some/api'

              after ->
                url = null

              it 'should redirect to proper url', ->
                expect(utils.setLocation).to.have.been
                  .calledWith '/foo'

            context 'and very profound request url', ->
              before ->
                url = 'https://example.edu.com/some/api?field=1#hook'

              after ->
                url = null

              it 'should redirect to proper url', ->
                expect(utils.setLocation).to.have.been
                  .calledWith 'https://example.edu.com/foo' +
                    '?destination=/my/location/'

        context 'with 403 (access denied)', ->
          before ->
            status = 403

          after ->
            status = null

          it 'should redirect to root route', ->
            expect(utils.redirectTo).to.have.been.calledWith {}

          it 'should send error notification', ->
            expect(publishEvent).to.have.been.calledWith 'notify'

          it 'should handle response', ->
            expect(xhr).to.have.property('errorHandled').and.equal true

          context 'and response JSON', ->
            before ->
              responseText = '{"error": "No access available"}'

            after ->
              responseText = null

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

          context 'when error is handled', ->
            before ->
              status = 403
              errorHandled = true

            after ->
              status = null
              errorHandled = null

            it 'should not redirect to root route', ->
              expect(utils.redirectTo).to.have.not.been.calledOnce

            it 'should not send error notification', ->
              expect(publishEvent).to.have.not.been.calledOnce

        context 'with a random failure', ->
          before ->
            status = 500

          after ->
            status = null

          it 'should send error notification', ->
            expect(publishEvent).to.have.been.calledWith 'notify'

          it 'should handle response', ->
            expect(xhr).to.have.property('errorHandled').and.equal true

          context 'and response JSON', ->
            before ->
              responseText = '{"message": "Operation failed!"}'

            after ->
              responseText = null

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
              responseText = '<html></html>'

            after ->
              responseText = null

            it 'should notify with default message', ->
              expect(publishEvent).to.have.been.calledWith 'notify',
                'There was a problem communicating with the server.'

          context 'when error is handled', ->
            before ->
              status = 500
              errorHandled = true

            after ->
              status = null
              errorHandled = null

            it 'should not send error notification', ->
              expect(publishEvent).to.have.not.been.calledOnce

        context 'when custom handler is set', ->
          before ->
            status = 500
            errorHandled = true
            customHandler = sinon.spy()

          after ->
            status = null
            errorHandled = null
            customHandler = null

          it 'should be called no matter what', ->
            expect(customHandler).to.have.been.calledOnce
