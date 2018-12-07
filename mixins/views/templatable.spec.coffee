import Chaplin from 'chaplin'
import Templatable from './templatable'
import templateMock from './templatable.spec.hbs'

class ViewMock extends Templatable Chaplin.View
  template: templateMock

describe 'Templatable', ->
  view = null
  template = null

  beforeEach ->
    view = new ViewMock()
    template = view.getTemplateFunction()

  afterEach ->
    view.dispose()

  it 'returns the template function', ->
    expect(template()).to.include '<h1>Foo</h1>'

  describe 'when no template function is set', ->
    beforeEach ->
      view.template = 'not-a-function'

    it 'throws an error', ->
      try
        view.getTemplateFunction()
      catch error
        message = error.message

      expect(message)
        .to.contain 'The template property must be a function.'
