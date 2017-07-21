define (require) ->
  Chaplin = require 'chaplin'
  FilterSelection = require 'models/filter-selection'

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
        new Chaplin.Model id: 'filterB'
        new Chaplin.Model id: 'filter3'
      ]
    new Chaplin.Model
      id: 'random'
      name: '$$$'
      required: yes
      children: new Chaplin.Collection [
        new Chaplin.Model id: '###'
        new Chaplin.Model id: '&&&'
      ]
  ]

  filtersObj =
    alphabet: ['filterA', 'filterB']
    digits: ['filter1', 'filterB']
    missing: 'value'
    random: '###'

  describe 'FilterSelection', ->
    collection = null

    beforeEach ->
      collection = new FilterSelection()

    afterEach ->
      collection.dispose()

    context 'fromObject', ->
      beforeEach ->
        collection.fromObject filtersObj, {filterGroups}

      it 'should exact number of filter items into selection', ->
        expect(collection.length).to.equal 5

      it 'should proper filter items into selection', ->
        filterA = collection.findWhere id: 'filterA'
        expect(filterA.attributes).to.eql
          id: 'filterA'
          groupId: 'alphabet'
          groupName: 'A-Z'
        filterB_1 = collection.findWhere id: 'filterB', groupId: 'alphabet'
        expect(filterB_1.attributes).to.eql
          id: 'filterB'
          groupId: 'alphabet'
          groupName: 'A-Z'
        filterB_2 = collection.findWhere id: 'filterB', groupId: 'digits'
        expect(filterB_2.attributes).to.eql
          id: 'filterB'
          groupId: 'digits'
          groupName: '0-9'
        filterVal = collection.findWhere id: 'value'
        expect(filterVal).to.be.undefined
        filterHm = collection.findWhere id: '###'
        expect(filterHm.attributes).to.eql
          id: '###'
          groupId: 'random'
          groupName: '$$$'
          required: yes

    context 'toObject', ->
      obj = null
      opts = null
      expectObj = null

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
            id: 'filterB'
            groupId: 'digits'
          new Chaplin.Model
            id: '###'
            groupId: 'random'
            required: yes
        ]
        obj = collection.toObject opts
        expectObj = _(filtersObj).omit('missing').value()

      it 'should generate proper object', ->
        expect(obj).to.eql expectObj

      context 'with custom options', ->
        before ->
          opts = compress: no

        it 'should generate proper object', ->
          expect(obj).to.eql _.extend {}, expectObj, random: ['###']
