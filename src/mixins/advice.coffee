# Helper mixin to include AOP capabilities via `flight`.
define (require, exports) ->
  advice = require 'flight/advice'

  exports = ->
    advice.withAdvice.call this unless @before
    this
