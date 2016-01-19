define (require) ->
  Notifications = require 'models/notifications'

  describe 'Notifications', ->
    beforeEach ->
      @collection = new Notifications()

    afterEach ->
      @collection.dispose()

    context 'on notifying a message', ->
      beforeEach ->
        @message1 = 'A message for you, Rudy!'
        @collection.publishEvent 'notify', @message1
      afterEach -> delete @message1

      it 'should add a message', ->
        expect(@collection).to.have.lengthOf 1
        expect(@collection.first().get('message')).to.equal @message1

      context 'on notifying another message', ->
        beforeEach ->
          @message2 = 'Something good just happened.'
          @collection.publishEvent 'notify', @message2
        afterEach -> delete @message2

        it 'should add a message', ->
          expect(@collection).to.have.lengthOf 2
          expect(@collection.at(1).get('message')).to.equal @message2

        context 'on notifying first message', ->
          beforeEach ->
            @collection.publishEvent 'notify', @message1

          it 'should remove existing message and re-add it again', ->
            expect(@collection).to.have.lengthOf 2
            expect(@collection.first().get('message')).to.equal @message2
            expect(@collection.at(1).get('message')).to.equal @message1
