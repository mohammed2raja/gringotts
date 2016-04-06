define (require) ->
  Chaplin = require 'chaplin'
  Automatable = require '../../mixins/automatable'
  StringTemplate = require '../../mixins/string-template'

  class View extends Automatable StringTemplate Chaplin.View
    autoRender: yes
    optionNames: @::optionNames.concat ['template']
