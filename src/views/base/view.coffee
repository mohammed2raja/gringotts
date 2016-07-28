define (require) ->
  Chaplin = require 'chaplin'
  StringTemplatable = require '../../mixins/views/string-templatable'

  class View extends StringTemplatable Chaplin.View
    autoRender: yes
