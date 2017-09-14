define (require) ->
  Chaplin = require 'chaplin'
  StringTemplatable = require '../../mixins/views/string-templatable'
  ErrorHandling = require '../../mixins/views/error-handling'

  class View extends ErrorHandling StringTemplatable Chaplin.View
    autoRender: yes
