helper = require '../../lib/mixin-helper'

###*
  * Helps publish 'notify' events for Notifications
###

module.exports = (superclass) -> helper.apply superclass, (superclass) -> \

class Notifying extends superclass
  helper.setTypeName @prototype, 'Notifying'

  notify: (message, opts) ->
    @publishEvent 'notify', message, opts

  notifySuccess: (message, opts) ->
    @notify message, _.extend {
      classes: 'alert-success'
      navigateDismiss: yes
    }, opts

  notifyError: (message, opts) ->
    @notify message, _.extend {
      classes: 'alert-danger'
      navigateDismiss: yes
    }, opts
