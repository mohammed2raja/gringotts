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

      beforeEach ->
        sandbox.spy utils, 'parseJSON'
        sandbox.stub utils, 'redirectTo'
        sandbox.stub utils, 'setLocation'
        sandbox.stub utils, 'reloadLocation'
        publishEvent = sinon.spy()
        originalBroker = Chaplin.EventBroker
        Chaplin.EventBroker = {publishEvent}
        ((window.I18n = {}).t = (text) -> text) if i18n
        errors.setupErrorHandling()

      afterEach ->
        $(document).off 'ajaxError'
        delete window.I18n
        Chaplin.EventBroker = originalBroker

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
            xhr = status: 401

          after ->
            xhr = null

          it 'should reload the window', ->
            expect(utils.reloadLocation).to.have.been.calledOnce

          context 'with redirect_url', ->
            before ->
              xhr.responseText = '{"redirect_url": "/foo"}'

            after ->
              xhr.responseText = null

            it 'should redirect to url', ->
              expect(utils.setLocation).to.have.been.calledWith '/foo'

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
