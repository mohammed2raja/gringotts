Chaplin = require 'chaplin'
backboneValidation = require 'backbone-validation'
Validatable = require 'mixins/models/validatable'
Validating = require 'mixins/views/validating'
Templatable = require 'mixins/views/templatable'

patterns = backboneValidation.patterns

class ModelMock extends Validatable Chaplin.Model
  validation:
    name:
      required: true
      pattern: 'name'
    email:
      required: true
      pattern: 'email'

class ViewMock extends Validating Templatable Chaplin.View
  autoRender: yes
  template: require 'validating-test.hbs'
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
    model = new ModelMock()
    view = new ViewMock {model}

  afterEach ->
    view.dispose()
    model.dispose()

  it 'should update model associated views', ->
    expect(model.associatedViews).to.include view

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
      model.validate()

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

      it 'should update model attributes', ->
        expect(model.get 'name').to.equal 'Johny'
        expect(model.get 'email').to.equal 'test@example.com'

      it 'should keep help blocks hidden and empty', ->
        expect(view.$ '.help-block').to.have.class 'hidden'
        expect(view.$ '.help-block').to.have.text ''

      context 'after another error', ->
        beforeEach ->
          view.$('[name="name"]').val('').trigger 'change'

        it 'should force update model attribute with invalid value', ->
          expect(model.get 'name').to.be.empty

  context 'on dispose', ->
    beforeEach ->
      view.dispose()

    it 'should remove view from model', ->
      expect(model.associatedViews).to.not.include view
