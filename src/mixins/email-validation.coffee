define (require) ->
  # Should match what we use in the backend
  # from this stackoverflow http://stackoverflow.com/questions/46155/
  regex = /^[^@]+@[^@]+\.[^@]+$/

  (superclass) -> class EmailValidation extends superclass
    validateEmail: (email) ->
      message = I18n?.t('error.validation.invalid_email') or 'Invalid Email'
      message if !regex.test email

    getEmailRegex: ->
      regex
