import Chaplin from 'chaplin'
import Changable from './changable'

class ChangableModel extends Changable Chaplin.Model
  defaults:
    d: 100

  parse: ({wrong}) ->
    a: wrong

class ChangableCollection extends Changable Chaplin.Collection
  comparator: (a, b) -> 1

describe 'Changable mixin', ->
  context 'for Model', ->
    model = null

    beforeEach ->
      model = new ChangableModel a: '1'

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

  context 'for Model with parsing', ->
    model = null

    beforeEach ->
      model = new ChangableModel {wrong: '1'}, parse: true

    afterEach ->
      model.dispose()

    it 'should not have changes by default', ->
      expect(model.hasChanges()).to.be.false

    context 'after change to the same parsed value', ->
      beforeEach ->
        model.set a: '1'

      it 'should not have changes', ->
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
      collection = new ChangableCollection [{a: '1'}, {b: '1'}], sort: no

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
