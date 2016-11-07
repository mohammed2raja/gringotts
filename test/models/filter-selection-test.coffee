define (require) ->
  Chaplin = require 'chaplin'
  FilterSelection = require 'models/filter-selection'

  filtersObj =
    alphabet: ['filterA', 'filterB']
    digits: ['filter1', 'filter2']
    random: ['###']

  describe 'FilterSelection', ->
    collection = null

    beforeEach ->
      collection = new FilterSelection()

    afterEach ->
      collection.dispose()

    context 'fromObject', ->
      beforeEach ->
        filterGroups = new Chaplin.Collection [
          new Chaplin.Model
            id: 'alphabet'
            name: 'A-Z'
            children: new Chaplin.Collection [
              new Chaplin.Model id: 'filterA'
              new Chaplin.Model id: 'filterB'
              new Chaplin.Model id: 'filterC'
            ]
          new Chaplin.Model
            id: 'digits'
            name: '0-9'
            children: new Chaplin.Collection [
              new Chaplin.Model id: 'filter1'
              new Chaplin.Model id: 'filter2'
              new Chaplin.Model id: 'filter3'
            ]
          new Chaplin.Model
            id: 'random'
            name: '$$$'
            children: new Chaplin.Collection [
              new Chaplin.Model id: '###'
              new Chaplin.Model id: '&&&'
            ]
        ]
        collection.fromObject filtersObj, filterGroups

      it 'should exact number of filter items into selection', ->
        expect(collection.length).to.equal 5

      it 'should proper filter items into selection', ->
        filterA = collection.findWhere id: 'filterA'
        expect(filterA.attributes).to.eql
          id: 'filterA'
          groupId: 'alphabet'
          groupName: 'A-Z'
        filter2 = collection.findWhere id: 'filter2'
        expect(filter2.attributes).to.eql
          id: 'filter2'
          groupId: 'digits'
          groupName: '0-9'
        filterHm =collection.findWhere id: '###'
        expect(filterHm.attributes).to.eql
          id: '###'
          groupId: 'random'
          groupName: '$$$'

    context 'toObject', ->
      obj = null

      beforeEach ->
        collection.add [
          new Chaplin.Model
            id: 'filterA'
            groupId: 'alphabet'
          new Chaplin.Model
            id: 'filterB'
            groupId: 'alphabet'
          new Chaplin.Model
            id: 'filter1'
            groupId: 'digits'
          new Chaplin.Model
            id: 'filter2'
            groupId: 'digits'
          new Chaplin.Model
            id: '###'
            groupId: 'random'
        ]
        obj = collection.toObject()

      it 'should generate proper object', ->
        expect(obj).to.eql filtersObj
