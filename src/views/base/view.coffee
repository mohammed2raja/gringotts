define (require) ->
  Chaplin = require 'chaplin'
  advice = require '../../mixins/advice'
  convenienceClass = require '../../mixins/convenience-class'
  stringTemplate = require '../../mixins/string-template'

  class View extends Chaplin.View
    advice.call @prototype
    stringTemplate.call @prototype
    convenienceClass.call @prototype

    autoRender: yes
    optionNames: Chaplin.View::optionNames.concat ['template']
