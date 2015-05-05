# This mixin will take a JSON blob that contains an `errors` hash
# **e.g.** `{...., "errors": {"PROP1": "msg", "PROP2": "msg2"...}}`
# and place a Bootstrap `.help-block` below the `input` whose
# selector matches `PROP` above. The content of said element will
# be the `msg` value associated with the `PROP`.
#
# Generic errors are specified with a `generic` key in the `errors`
# hash where the messages are listed in an array as the values of
# the key.
#
# We default to using the `name` attribute, but other attributes can be
# specified via the `opts` hash with `inputAttr`.
#
# `id` and `class` attributes will use the appropriate selectors.
define (require, exports) ->
  _ = require 'underscore'

  # Map of the different methods for each attribute type.
  selectorFns =
    id: (field) -> "##{field}"
    class: (field) -> ".#{field}"
    other: (field) -> "[#{selectedAttr}='#{field}']"

  # `opts` configurables
  genericErrMsg = ''
  selector = ''
  selectedAttr = ''
  specificErrors = false

  # Helper method to wrap message in Bootstrap element.
  errorBlock = (error) ->
    "<p class='help-block'>#{error}</p>"

  # These can be overriden after being mixed in to configure the type
  # of query used, DOM insertion method and/or the content added.
  genericError = (error) ->
    @$('form:first').prepend errorBlock error
  specificError = (query, error) ->
    @$("#{query}:first").after errorBlock error

  parseErrors = (errors) ->
    # Display generic error string if there are no errors.
    # This string can be configured with `opts.genericErrMsg`.
    if !errors or _.isEmpty errors
      return @genericError genericErrMsg
    # Show any generic errors at the top of the form.
    errorStrings = errors.generic
    if _.isArray(errorStrings) and errorStrings.length > 0
      _.each errorStrings, (err) ->
        @genericError err
      , this
    else
      # Listen to this event to do any specific logic or
      # processing before specific errors are applied if
      # specified via `opts.specificErrors`.
      @trigger 'specificErrors:before', errors if specificErrors

      _.each errors, (val, field) ->
        @specificError selector(field), errors[field]
      , this

  # For the time being, the mixin supports only a single form per (sub)?view.
  exports = (opts = {}) ->
    # Message to display for general/parse errors.
    genericErrMsg =
      opts.genericErrMsg or 'There was a problem. Please try again.'

    # Flag for firing event before handling specific errors.
    specificErrors = opts.specificErrors

    # Determine the type of selector the library will use.
    selectedAttr = opts.inputAttr or 'name'
    selector = selectorFns[selectedAttr] or selectorFns.other

    @genericError = genericError
    @specificError = specificError
    @parseErrors = parseErrors
    this
