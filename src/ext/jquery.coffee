# This is meant to be used in the application bootstrapping code such as
# application.coffee where invoking it in an init block will attach itself once
# globally.
define (require) ->
  utils = require 'lib/utils'

  exports =
    setupError: (context) ->
      $(document).ajaxError (event, jqXHR, options, error) ->
        {status} = jqXHR
        if status is 401
          session = utils.parseJSON jqXHR.responseText
          # `session` will be an object or false.
          if session.CODE is 'SESSION_EXPIRED'
            # Since the session is now expired reloading a page will trigger an
            # auth check and bounce the user to the login page. Because of that
            # after they successfully log back in they should be redirected back
            # here.
            (context or window).location.reload()
