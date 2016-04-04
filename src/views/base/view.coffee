define (require) ->
  Chaplin = require 'chaplin'
  ConvenienceClass = require '../../mixins/convenience-class'
  StringTemplate = require '../../mixins/string-template'

  class View extends ConvenienceClass StringTemplate Chaplin.View
    autoRender: yes
    optionNames: @::optionNames.concat ['template']
