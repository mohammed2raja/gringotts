import Notifications from './notifications'

describe 'Notifications', ->
  collection = null
  listenGlobal = true

  beforeEach ->
    collection = new Notifications(null, listenGlobal: listenGlobal)

  afterEach ->
    collection.dispose()

  context 'on notifying a message', ->
    message1 = null

    beforeEach ->
      message1 = 'A message for you, Rudy!'
      collection.publishEvent 'notify', message1
    afterEach -> message1 = null

    it 'should add a message', ->
      expect(collection).to.have.lengthOf 1
      expect(collection.first().get('message')).to.equal message1

    context 'on notifying another message', ->
      message2 = null

      beforeEach ->
        message2 = 'Something good just happened.'
        collection.publishEvent 'notify', message2
      afterEach -> message2 = null

      it 'should add a message', ->
        expect(collection).to.have.lengthOf 2
        expect(collection.at(1).get('message')).to.equal message2

      context 'on notifying first message', ->
        beforeEach ->
          collection.publishEvent 'notify', message1

        it 'should remove existing message and re-add it again', ->
          expect(collection).to.have.lengthOf 2
          expect(collection.first().get('message')).to.equal message2
          expect(collection.at(1).get('message')).to.equal message1

    context 'on listenGlobal false', ->
      before ->
        listenGlobal = false

      after ->
        listenGlobal = true

      context 'on notifying a message', ->
        message1 = null

        beforeEach ->
          message1 = 'A message for you, Rudy!'
          collection.publishEvent 'notify', message1

        afterEach -> message1 = null

        it 'should not add a message', ->
          expect(collection).to.have.lengthOf 0
