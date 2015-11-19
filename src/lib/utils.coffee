# Typically, a project will create their own `utils` file/object to beget
# `Chaplin.utils` and add their own methods. Feel free to map this file to
# a more suitable path in `require.config`.

# See [Chaplin utils](https://github.com/chaplinjs/chaplin-boilerplate/blob/master/coffee/lib/utils.coffee)
# for an example.
define (require) ->
  Backbone = require 'backbone'
  Chaplin = require 'chaplin'

  # Alias to DOM library provided.
  $ = Backbone.$

  # Delegate to the `Chaplin.utils` module
  utils = Chaplin.utils.beget Chaplin.utils

  # Returns a string representation of an HTML node of type `tagName` wrapping
  # `content` with HTML attributes `attrs`.
  utils.tagBuilder = (tagName, content, attrs, escape=yes) ->
    tag = $ "<#{tagName}>"
    if escape
      # `.text()` escapes the string it's given which we want
      tag.text content
    else
      tag.html content
    tag.attr(attrs) if attrs
    tag[0].outerHTML

  # Used in flight/compose in flight/advice.
  utils.isEnumerable = (obj, property) ->
    Object.keys(obj).indexOf(property) > -1

  utils.parseJSON = (str) ->
    result = false

    try
      result = JSON.parse str
    catch error
      # Improve tag value of falsy values.
      if typeof str is 'undefined'
        str = 'undefined'
      else if str.length is 0
        str = 'Empty string'
      Raven?.captureException error, tags: {str}

    result

  utils
