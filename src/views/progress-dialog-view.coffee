define (require) ->
  ModalView = require './base/modal-view'
  templates = require('templates')

  STATES = ['default', 'progress', 'error', 'success']

  ###*
  * A dialog view that shows the pulsing progress indicator
  * during model's activity.
  * On model synced, displays the success view.
  * On model error, displays the error view with an option to try again.
  * Initialized with set of key objects (states):
  *   <default, progress, error, success>:
  *     title: String
  *     text: <String, Function>
  *     buttons: [{text: String, className: String, click: Function}]
  * State text can be a Handlebars template function.
  * If a button doesn't have click handler, it will close dialog on click.
  ###
  class ProgressDialogView extends ModalView
    optionNames: @::optionNames.concat STATES, ['state', 'onDone', 'onCancel']
    className: 'progress-dialog'
    template: 'progress-dialog'
    onDone: null
    onCancel: null
    state: null
    listen:
      'syncing model': -> @onSyncing()
      'synced model': -> @onSynced()
      'error model': (model, $xhr) -> @onError $xhr
    events:
      'show.bs.modal': ->
        @$stateView().removeClass 'fade' # to enable BS animation
      'shown.bs.modal': ->
        @$stateView().addClass 'fade'
      'click button': (e) ->
        $btn = $(e.currentTarget)
        @[@state]?.buttons.forEach (b) =>
          b.click.call this, e if b.click and $btn.hasClass b.className
      'hide.bs.modal': ->
        @$stateView().removeClass 'fade' # to enable BS animation
      'hidden.bs.modal': ->
        if @state is 'success' then @onDone?() else @onCancel?()

    initialize: ->
      super
      if not _.isFunction @model.isSyncing
        throw Error 'Requires a model implementing SyncMachine'
      # set a few essential defaults for basic dialog use cases
      _.defaultsDeep this,
        default:
          buttons: [
            text: I18n?.t('buttons.OK') or 'OK',
            className: 'btn-primary confirm-button'
          ]
        error:
          title: I18n?.t('error.try_again') or 'Try again?'
          text: I18n?.t('error.did_not_work') or "Hmm. That didn't
            seem to work."
          buttons: [
            # stealing action button's style and click handler to try again
            _.extend (_.clone _.first _.filter @default?.buttons,
                (b) -> b.click),
              text: I18n?.t('buttons.try_again') or 'Try again'
          ]
        success:
          # using a template with check icon
          html: => templates['progress-success'] @getTemplateData()
          buttons: [
            text: I18n?.t('buttons.Okay') or 'Okay',
            className: 'btn-primary confirm-button'
          ]
      # link hbs templates to template data
      STATES.forEach (s) =>
        if @[s] and _.isFunction @[s].text
          @[s].html = => @[s].text @getTemplateData()
      # set initial state if it's not defined by user
      @state = @progressState() unless @state

    getTemplateData: ->
      _.extend super, {@state}, _.reduce STATES, (data, state) =>
        data[state] = @[state]
        data
      , {}

    render: ->
      super
      if @model.isSyncing() then @onSyncing()

    onSyncing: ->
      @setLoading on
      @switchTo @progressState()

    onSynced: ->
      @setLoading off
      @switchTo 'success'

    onError: ($xhr) ->
      $xhr.errorHandled = yes
      @setLoading off
      @switchTo 'error'

    switchTo: (state) ->
      return if @state is state
      @state = state
      # re-render in case if hbs template shows model updated data
      if @[state]?.html
        @$stateView().find('.modal-body').html @[state].html()
      _.each STATES, (s) => @$stateView(s).addClass('fade').toggleClass 'in',
          s is state and not @empty state

    empty: (state) ->
      return yes unless @[state]
      return not @[state].title and not @[state].text and not @[state].html

    setLoading: (loading) ->
      @$('.loading').toggleClass 'in', loading

    $stateView: (state=@state) ->
      @$(".#{state}-state-view")

    progressState: ->
      if @model.isSyncing() and @progress then 'progress' else 'default'
