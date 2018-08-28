import Chaplin from 'chaplin'
import NotificationView from 'views/notification-view'

describe 'NotificationView', ->
  sandbox = null
  success = null
  undo = null
  model = null
  view = null
  undoSelector = null
  useFakeTimers = yes

  beforeEach ->
    sandbox = sinon.createSandbox {useFakeTimers}
    success = sinon.spy()
    undo = sinon.spy()
    opts = {success, undo, model: new Chaplin.Model()}
    model = new Chaplin.Model {opts}
    viewOpts = {model, fadeSpeed: 0}
    viewOpts.undoSelector = undoSelector if undoSelector
    view = new NotificationView viewOpts
    view.getTemplateFunction = ->
      -> '<button type="button" class="close">&times;</button>'
    sinon.spy view, 'dismiss'

  afterEach ->
    sandbox.restore()
    view.dispose()
    model.dispose()

  it 'should dismiss itself after a few seconds', ->
    sandbox.clock.tick 4500
    expect(view.dismiss).to.have.been.called
    expect(success).to.have.been.called

  it 'should be manually dismissed', ->
    view.$('.close').click()
    expect(view.dismiss).to.have.been.called

  it 'should only show an undo link conditionally', ->
    model.set 'opts', {}
    view.render()
    expect(view.$ '.undo').not.to.exist

  it 'should be able to add an undo element', ->
    expect(view.$ '.undo').to.exist

  it 'should display only one undo at a time', ->
    sandbox.spy $.fn, 'remove'
    sinon.spy view, 'getUndoElement'
    view.render()
    expect($.fn.remove).to.be.calledOnce
    expect(view.getUndoElement).to.be.calledOnce

  it 'should invoke callback before device is disposed', ->
    model.get('opts').model.trigger 'dispose'
    expect(success).to.have.been.called

  context 'dismiss on navigation', ->
    path = ''
    previous = {}

    beforeEach ->
      model.set 'opts', navigateDismiss: yes
      # Kick off logic during construction.
      view.initialize()
      view.publishEvent 'dispatcher:dispatch',
        {}, {}, {path, previous}

    context 'navigation to different primary route', ->
      before ->
        path = 'main_path/subpath'
        previous =
          path: 'another_main_path'

      after ->
        path = ''
        previous = {}

      it 'should dispose on navigation to main path', ->
        expect(view.dismiss).to.be.calledOnce

    context 'navigation to same route with different query params', ->
      before ->
        path = 'main_path?q=1'
        previous =
          path: 'main_path?q=2'

      after ->
        path = ''
        previous = {}

      it 'should not dispose on navigation to subpath', ->
        expect(view.dismiss).not.to.be.called

  it 'should not call the timeout with the sticky option', ->
    sinon.stub window, 'setTimeout'
    model.set 'opts', sticky: yes
    model.timeout = null
    view.render()
    expect(window.setTimeout).not.to.be.called
    expect(model.timeout).not.to.exist

  it 'should allow the timeout to be changed', ->
    view.reqTimeout = 888
    view.render()
    sandbox.clock.tick 888
    expect(success).to.have.been.called
    expect(model.timeout).to.exist

  it 'should allow instances to change the timeout', ->
    model.set 'opts', reqTimeout: 101
    view.render()
    sandbox.clock.tick 101
    expect(view.dismiss).to.have.been.calledOnce

  context 'should allow the undo selector to be changed', ->
    before -> undoSelector = '#undo'
    after -> undoSelector = null

    beforeEach ->
      view.$el.append '<a id="undo">'
      view.$('#undo').click()

    it 'should invoke model.undo', ->
      expect(undo).to.have.been.called

  it 'should add specified classes', ->
    model.set 'opts', classes: 'none'
    view.attach()
    expect(view.$el).to.have.class 'none'

  it 'should add default class', ->
    view.attach()
    expect(view.$el).to.have.class 'alert-success'

  context 'on undo', ->
    beforeEach ->
      expect(view.$ '.undo').to.exist
      view.$('.undo').click()

    it 'should dismiss', ->
      expect(view.dismiss).to.have.been.called
      expect(undo).to.have.been.called

    it 'does not call the success method', ->
      sandbox.clock.tick 4500
      expect(success).not.to.be.called

  context 'on dismiss', ->
    beforeEach ->
      sandbox.stub(_, 'delay').callsFake (fn) -> fn()

    it 'should dispose the model', ->
      view.dismiss()
      expect(model.disposed).to.be.true

    it 'should not dispose the model if it is already disposed', ->
      sinon.spy model, 'dispose'
      model.dispose()
      view.dismiss()
      expect(model.dispose).to.be.calledOnce

    it 'should not raise errors without an element', ->
      $el = view.$el
      view.$el = null
      view.dismiss()
      view.$el = $el

  context 'with a deferred (like an AJAX request)', ->
    before ->
      useFakeTimers = null

    after ->
      useFakeTimers = yes

    beforeEach ->
      deferred = $.Deferred()
      model.set 'opts', {deferred}
      view.render()
      deferred.resolve()

    it 'should dismiss when it succeeds', ->
      expect(view.dismiss).to.have.been.called

  context 'with an arbitrary click handler', ->
    handler = null

    beforeEach ->
      handler = sinon.spy()
      model.set 'opts', click: {selector: '.arbitrary', handler}
      view.getTemplateFunction = ->
        -> 'Some text <a href="#" class="arbitrary">A link</a>'
      view.render()

    it 'should execute the handler', ->
      view.$('.arbitrary').click()
      expect(handler).to.have.been.called

  it 'should append arbitrary links', ->
    model.set 'opts', link: '<a href="#" class="arbitrary">A link</a>'
    view.render()
    expect(view.$ '.arbitrary').to.exist
