define (require) ->
  Chaplin = require 'chaplin'
  EmailValidation = require 'mixins/email-validation'

  class MockModel extends EmailValidation Chaplin.Model

  describe 'EmailValidation', ->
    model = null

    beforeEach ->
      model = new MockModel()

    it 'should validate correct email as valid', ->
      expect(model.validateEmail 'test@example.com').to.be.undefined

    it 'should validate correct email as invalid', ->
      expect(model.validateEmail '@example.com').to.eq 'Invalid Email'
