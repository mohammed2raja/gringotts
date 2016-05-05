define (require) ->
  Chaplin = require 'chaplin'
  StringTemplatable = require '../../mixins/string-templatable'

  class View extends StringTemplatable Chaplin.View
    autoRender: yes
