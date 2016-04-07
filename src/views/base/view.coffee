define (require) ->
  Chaplin = require 'chaplin'
  Automatable = require '../../mixins/automatable'
  StringTemplatable = require '../../mixins/string-templatable'

  class View extends Automatable StringTemplatable Chaplin.View
    autoRender: yes
