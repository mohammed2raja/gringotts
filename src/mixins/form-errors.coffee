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
define (require) ->
  # Map of the different methods for each attribute type.
  selectorFns =
    id: (field) -> "##{field}"
    class: (field) -> ".#{field}"
    other: (field, attr) -> "[#{attr}='#{field}']"

  # Helper method to wrap message in Bootstrap element.
  errorBlock = (error) ->
    "<p class='help-block'>#{error}</p>"

  (superclass) -> class FormErrors extends superclass
    # Message to display for general/parse errors.
    genericErrMsg: 'There was a problem. Please try again.'

    # Flag for firing event before handling specific errors.
    specificErrors: false

    # Determine the type of selector the library will use.
    inputAttr: 'name'

    _formErrorSelector: (field) ->
      (selectorFns[@inputAttr] or selectorFns.other) field, @inputAttr

    # These can be overriden after being mixed in to configure the type
    # of query used, DOM insertion method and/or the content added.
    genericError: (error) ->
      @$('form:first').prepend errorBlock error

    specificError: (query, error) ->
      @$("#{query}:first").after errorBlock error

    parseErrors: (errors) ->
      # Display generic error string if there are no errors.
      # This string can be configured with `@genericErrMsg`.
      return @genericError @genericErrMsg if !errors or _.isEmpty errors
      # Show any generic errors at the top of the form.
      if _.isArray(errors.generic) and errors.generic.length > 0
        _.each errors.generic, (err) => @genericError err
      else
        # Listen to this event to do any specific logic or
        # processing before specific errors are applied if
        # specified via `@specificErrors`.
        @trigger 'specificErrors:before', errors if @specificErrors

        _.each errors, (val, field) =>
          @specificError @_formErrorSelector(field), errors[field]
