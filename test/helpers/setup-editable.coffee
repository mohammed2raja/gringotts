define (require) ->
  before: ->
    @field ||= '.name-field'
    @click ||= '.edit-name'
    @view.$(@click).click()
    @value = 'Peter Bishop' if @value is undefined
    @view.$(@field).text @value
    event = if @event is undefined then @enter else @event
    @view.$(@field).trigger event

  after: ->
    # FIXME: since error state is tracked globally it has to be reset after
    # each test. it should not be tracked globally
    @view.$(@field).text('Peter Bishop').trigger @enter
    delete @click
    delete @field
