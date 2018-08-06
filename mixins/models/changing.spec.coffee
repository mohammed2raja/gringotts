import Chaplin from 'chaplin'
import Changing from './changing'

class ChangingModel extends Changing Chaplin.Model

class ChangingCollection extends Changing Chaplin.Collection
  comparator: (a, b) -> 1

describe 'Changing mixin', ->
  context 'for Model', ->
    model = null

    beforeEach ->
      model = new ChangingModel a: '1'

    afterEach ->
      model.dispose()

    it 'should not have changes by default', ->
      expect(model.hasChanges()).to.be.false

    context 'after change', ->
      beforeEach ->
        model.set c: '1'

      it 'should have changes', ->
        expect(model.hasChanges()).to.be.true

      context 'on sync', ->
        beforeEach ->
          model.trigger 'sync', model

        it 'should not have changes', ->
          expect(model.hasChanges()).to.be.false

  context 'for Collection', ->
    collection = null

    beforeEach ->
      collection = new ChangingCollection [{a: '1'}, {b: '1'}], sort: no

    afterEach ->
      collection.dispose()

    it 'should not have changes by default', ->
      expect(collection.hasChanges()).to.be.false

    context 'on sort', ->
      beforeEach ->
        collection.sort()

      it 'should not have changes', ->
        expect(collection.hasChanges()).to.be.false

    context 'after change', ->
      beforeEach ->
        collection.head().set c: '1'

      it 'should have changes', ->
        expect(collection.hasChanges()).to.be.true

      context 'on sync', ->
        beforeEach ->
          collection.trigger 'sync', collection

        it 'should not have changes', ->
          expect(collection.hasChanges()).to.be.false
