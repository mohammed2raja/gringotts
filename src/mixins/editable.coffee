#coffeelint: disable=cyclomatic_complexity
define (require) ->
#coffeelint: enable=cyclomatic_complexity
  DEFAULTS =
    errorClass: 'error-input'

  # Try to convert attribute into a number.
  convertNumber = (attr) ->
    convertNum = parseInt attr, 10
    # Throw out strings and floats.
    if convertNum is +attr then convertNum else attr

  # Remove classes and events attached by this mixin.
  # Returns a reference to $field
  cleanEl = (opts) ->
    opts.$field.removeClass opts.errorClass
      .removeAttr 'contenteditable'
      .off '.gringottsEditable'
      .removeAttr 'data-toggle'
      .removeAttr 'title'
      .removeAttr 'data-original-title'
      .tooltip 'destroy'
    opts.clean.call this, opts if opts.clean
    opts.$field

  # Accept protocol, email and tel links.
  # All others will be made protocol relative.
  updateLink = (opts) ->
    if /^(mailto|tel):/.test opts.href
      # Update the email or tel link.
      opts.$field.attr 'href', opts.href.replace(opts.original, opts.value)
    else if opts.value.indexOf('http') is 0
      opts.$field.attr 'href', opts.value
    else
      # Make protocol URI.
      opts.$field.attr 'href', "//#{opts.value}"

  # Sanitize the input.
  # HTML entities are automatically escaped.
  checkInput = (opts) ->
    opts.value = opts.$field.text()
    (attrs = {})[opts.attribute] = opts.value
    # We only want to validate specific attributes.
    errorExists = opts.model.validationError = opts.model.validate attrs
    if errorExists
      opts.$field.focus().addClass opts.errorClass
      if _.isString errorExists[opts.attribute]
        opts.$field.attr 'data-toggle', 'tooltip'
          .attr 'title', errorExists[opts.attribute]
        opts.$field.tooltip('show').data('bs.tooltip')
        .tip().addClass 'error-tooltip'
      document.execCommand 'selectAll', no, null
      opts.error.call this, errorExists, opts if opts.error
    else
      cleanEl.call this, opts
      # Type cast value as necessary.
      opts.value = convertNumber opts.value
      unless opts.original is opts.value
        # For update/undo the link.
        opts.href = opts.$field.attr('href') or ''
        opts.success.call this, opts if opts.success
        # Mirror content change to href attribute.
        updateLink opts if opts.href

  (superclass) -> class Editable extends superclass
    makeEditable: (opts) ->
      # cancel if there are other active editable (due to validation errors)
      return if $('[data-edit][contenteditable]').length

      opts.attribute = opts.$field.data 'edit'
      opts.original = opts.model.get(opts.attribute) or ''

      # Setup event handlers for editable.
      opts.$field.attr 'contenteditable', yes
        .focus()
        # Inline handler methods to pass view scope in.
        .on('keydown.gringottsEditable', (evt) =>
          keyCode = evt.keyCode
          # Prevent newlines in output from Enter key.
          if keyCode is 13
            evt.preventDefault()
            checkInput.call this, opts
          # Cancel and undo edits with Esc key.
          else if keyCode is 27
            opts.model.validationError = null
            cleanEl.call(this, opts).text opts.original
        )
        # Clicking an outside element on error will cause a strange state
        # because the click takes focus away from element (still editable).
        .on('blur.gringottsEditable', =>
          checkInput.call this, opts
        )
        #coffeelint: disable=max_line_length
        # Taken from `http://stackoverflow.com/questions/12027137/javascript-trick-for-paste-as-plain-text-in-execcommand`
        #coffeelint: enable=max_line_length
        .on 'paste.gringottsEditable', (evt) ->
          # Cancel paste
          evt.preventDefault()
          # Get text representation of clipboard from original event.
          text = evt.originalEvent.clipboardData.getData 'text/plain'
          # Insert text manually unformatted.
          document.execCommand 'insertHTML', no, text

      document.execCommand 'selectAll', no, null

    # Entry point method to specify a `field` to be `contenteditable` and update
    # the view's `@model`'s `data-edit` attribute on blur.
    #
    # `opts` accepts keys success, error, errorClass
    # Anything else will be passed to the callbacks.
    #
    # `success`, `error`, and `clean` callbacks are invoked after the field
    # loses focus. This can happen by blur or enter. If escape is pressed it
    # reverts the field to the original value. After blur or enter it will
    # validate the new value and invoke `success` or `error` depending on
    # the result. Callbacks will be invoked with the view they were mixed
    # into as their context.
    #
    # This works off the assumption that only one editable is used at a time.
    # The editable should be a DOM node with a sole child text element
    # or compatible link. Links will use the same `href` as it's value
    # (made protocol-relative if not specified), except for emails and
    # telephone numbers which will have the correct prefix prepended.
    #
    # In cases where the user attempts to use an editable after another one,
    # you may end up unable to undo the first one (if using the notification
    # mixin) because the blur handler of the second will "commit" the first.
    #
    # If the value can be properly coerced into a Number, that will be used
    # as the result to save to the server.
    setupEditable: (clickTarget, field, opts={}) ->
      @delegate 'click', clickTarget, (evt) ->
        evt.preventDefault()
        _.defaults opts, DEFAULTS
        opts.$field = @$(field)
        opts.model ||= @model
        @makeEditable opts
