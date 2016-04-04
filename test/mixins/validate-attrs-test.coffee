define (require) ->
  Chaplin = require 'chaplin'
  validateAttrs = require 'mixins/validate-attrs'

  describe 'Validate attributes mixin', ->
    model = null

    beforeEach ->
      model = new Chaplin.Model name: 'Evelyn'
      model.validateName = (text) ->
        'name too long' if text.length > 7
      sinon.spy model, 'validateName'
      validateAttrs.call model, methods: {
        name: 'validateName'
      }
    afterEach ->
      model.dispose()

    it 'returns falsy with no errors', ->
      expect(model.isValid()).to.be.true
      expect(model.validateName).to.be.calledOnce

    it 'returns an object with erroneous values for invalid values', ->
      model.set {'age'}
      model.validateAge = (age) -> 'missing' unless typeof age is 'number'
      validateAttrs.call model, methods: {
        age: 'validateAge'
      }
      model.isValid()
      expect(model.validationError.age).to.equal 'missing'

    it 'accepts falsy values', ->
      model.set superuser: null
      model.validateSU = (val) -> val
      sinon.spy model, 'validateSU'
      validateAttrs.call model, methods: {
        superuser: 'validateSU'
      }
      expect(model.isValid()).to.be.true
      expect(model.validateSU).to.be.calledOnce

    it 'defaults to a blank check', ->
      model.set {'title'}
      validateAttrs.call model, methods: {
        name: 'validateName'
        title: 'blank'
      }
      expect(model.isValid()).to.be.true

    it 'only validates attributes with methods', ->
      model.set {title: ''}
      expect(model.isValid()).to.be.true

    it 'only validates attributes specified', ->
      model.set {'status'}
      model.validateStatus = -> 'invalid status'
      validateAttrs.call model, methods: {
        name: 'validateName'
        status: 'validateStatus'
      }
      valid = model.validate name: model.get 'name'
      expect(valid).not.to.be.ok

    it 'works with multiple models', ->
      model = new Chaplin.Model name: 'Eve'
      model.validateName = (text) ->
        'name too long' if text.length > 5
      sinon.spy model, 'validateName'
      validateAttrs.call model, methods: {
        name: 'validateName'
      }
      expect(model.isValid()).to.be.true
      expect(model.isValid()).to.be.true
      expect(model.validateName).to.be.calledTwice
      model.dispose()

    it 'can validate attributes on the model', ->
      model.validateName = ->
        'name too long' if @get('name').length > 5
      expect(model.isValid()).to.be.false

    it 'returns proper validate error for blank check', ->
      model.set {'test': null}
      validateAttrs.call model, methods: test: 'missingMethod'
      expect(model.isValid()).to.be.false
      expect(model.validationError).to.eql test: 'Value Required'
