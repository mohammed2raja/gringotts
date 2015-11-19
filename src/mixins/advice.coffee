# Helper mixin to include AOP capabilities via `flight`.
define (require) ->
  advice = require 'flight/advice'

  ->
    advice.withAdvice.call this unless @before
    this
