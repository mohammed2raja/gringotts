define (require) ->
  patterns = require('backbone_validation').patterns
  Validatable = require 'mixins/validatable'
  Validating = require 'mixins/validating'
  StringTemplatable = require 'mixins/string-templatable'
  Model = require 'models/base/model'
  View = require 'views/base/view'

  class MockModel extends Validatable Model
    validation:
      name:
        required: true
        pattern: 'name'
      email:
        required: true
        pattern: 'email'

  class MockView extends Validating StringTemplatable View
    template: 'validating-test'
    templatePath: 'test/templates'
    bindings:
      '[name="name"]': 'name'
      '[name="email"]': 'email'

    render: ->
      super
      @stickit()

  describe 'Validating', ->
    view = null
    model = null

    beforeEach ->
      model = new MockModel()
      view = new MockView {model}

    afterEach ->
      view.dispose()
      model.dispose()

    it 'should apply regex patterns', ->
      expect(view.$ '#adminName').to.have.prop 'pattern',
        patterns.name.source
      expect(view.$ '#adminEmail').to.have.prop 'pattern',
        patterns.email.source

    it 'should keep help blocks hidden', ->
      expect(view.$ '.help-block').to.have.class 'hidden'

    it 'should have template data with all regex patterns', ->
      data = view.getTemplateData()
      expect(_.keys data.regex).to.eql _.keys patterns

    context 'on validation with errors', ->
      beforeEach ->
        model.isValid true

      it 'should keep help blocks visible', ->
        expect(view.$ '.help-block').to.not.have.class 'hidden'

      it 'should have error classes applied', ->
        expect(view.$ '.form-group').to.have.class 'has-error'

      it 'should have error messages', ->
        expect(view.$('#adminName').next '.help-block').to.have
          .text 'Name is required'
        expect(view.$('#adminEmail').next '.help-block').to.have
          .text 'Email is required'

      context 'after error fixed', ->
        beforeEach ->
          view.$('[name="name"]').val('Johny').trigger 'change'
          view.$('[name="email"]').val('test@example.com').trigger 'change'

        it 'should keep help blocks hidden and empty', ->
          expect(view.$ '.help-block').to.have.class 'hidden'
          expect(view.$ '.help-block').to.have.text ''
