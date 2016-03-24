define (require) ->
    # Should match what we use in the backend
    # from this stackoverflow http://stackoverflow.com/questions/46155/
  regex = /// ^
    (([^<>()\[\]\\.,;:\s@\"]+(\.[^<>()\[\]\\.,;:\s@\"]+)*)|(\".+\"))
    @
    ((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])
    |
    (([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))
    $ ///

  ->
    @validateEmail = (email) ->
      message = I18n?.t('error.validation.invalid_email') or 'Invalid Email'
      message if !regex.test email
    @getEmailRegex = ->
      regex

    this
