define (require, exports) ->
    # Should match what we use in the backend
    # from this stackoverflow http://stackoverflow.com/questions/46155/
  regex = /// ^
    (([^<>()\[\]\\.,;:\s@\"]+(\.[^<>()\[\]\\.,;:\s@\"]+)*)|(\".+\"))
    @
    ((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])
    |
    (([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))
    $ ///

  exports = ->
    @validateEmail = (email) ->
      # False for valid emails to work with validate-attrs mixin.
      !regex.test email
    @getEmailRegex = ->
      regex

    this
