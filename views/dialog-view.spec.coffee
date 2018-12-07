import DialogView from './dialog-view'

describe 'DialogView', ->
  title = 'Secret Operation'
  text = 'Are you ready to know?'
  view = null
  clickSpy = null

  beforeEach ->
    sinon.stub $.fn, 'modal'
    clickSpy = sinon.spy()
    view = new DialogView {
      title, text,
      buttons: [
        {text: 'Yes', className: 'btn-primary', click: clickSpy}
        {text: 'No', className: 'btn-link'}
      ]
    }
    view.render()

  afterEach ->
    $.fn.modal.restore()
    view.dispose() unless view.disposed

  it 'should have title set', ->
    expect(view.$ '.modal-title').to.have.text title

  it 'should have text set', ->
    expect(view.$ '.modal-body').to.have.text text

  it 'should have buttons renderred', ->
    expect(view.$ '.btn.btn-primary').to.exist.and.to.have.text 'Yes'
    expect(view.$ '.btn.btn-link').to.exist.and.to.have.text 'No'

  context 'on action click', ->
    beforeEach ->
      view.$('.btn.btn-primary').trigger 'click'

    it 'should invoke click handler', ->
      expect(clickSpy).to.have.been.calledWith sinon.match.object
