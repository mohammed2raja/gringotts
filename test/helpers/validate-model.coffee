define (require, exports) ->
  Chaplin = require 'chaplin'

  exports = class FakeModel extends Chaplin.Model
    # Default validation criterion for editable field.
    validate: (attrs, opts) ->
      for attr, val of attrs
        return 'attribute is empty' if val.length is 0
      undefined
