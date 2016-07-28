define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  StringTemplatable = require '../../mixins/views/string-templatable'
  ServiceErrorReady = require '../../mixins/views/service-error-ready'

  class CollectionView extends utils.mix Chaplin.CollectionView
      .with StringTemplatable, ServiceErrorReady
    loadingSelector: '.loading'
    fallbackSelector: '.empty'
    useCssAnimation: yes
    animationStartClass: 'fade'
    animationEndClass: 'in'
