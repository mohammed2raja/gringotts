import Chaplin from 'chaplin'

export default class ValidateModelMock extends Chaplin.Model
  url: 'dummy'
  # Default validation criterion for editable field.
  validate: (attrs, opts) ->
    for attr, val of attrs
      if val.length is 0
        result = {}
        result[attr] = 'attribute is empty'
        return result
    undefined
