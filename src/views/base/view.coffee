define (require) ->
  Chaplin = require 'chaplin'
  advice = require '../../mixins/advice'
  convenienceClass = require '../../mixins/convenience-class'
  stringTemplate = require '../../mixins/string-template'

  class View extends Chaplin.View
    _.extend @prototype, stringTemplate
    advice.call @prototype
    convenienceClass.call @prototype

    autoRender: yes
    optionNames: Chaplin.View::optionNames.concat ['template']
