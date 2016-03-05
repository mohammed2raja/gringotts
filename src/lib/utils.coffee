#coffeelint: disable=max_line_length
# Typically, a project will create their own `utils` file/object to beget
# `Chaplin.utils` and add their own methods. Feel free to map this file to
# a more suitable path in `require.config`.

# See [Chaplin utils](https://github.com/chaplinjs/chaplin-boilerplate/blob/master/coffee/lib/utils.coffee)
# for an example.
#coffeelint: enable=max_line_length
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

  ###*
   * Generates a convenient css class name for QE purposes.
   * Assumingly it's being used for every view in the application.
   * @param  {String} className Existing view's class name.
   * @param  {String} template  View's template path.
   * @return {String}           A newly generated class name using template.
  ###
  utils.convenienceClass = (className, template) ->
    if template
      convenient = template.replace /\//g, '-'
      original = if className then " #{className}" else ''
      className = "#{convenient}#{original}"
    className

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

  ###*
   * Processes hbs helper arguments and extracts funcs and vars
   * @param  {Object} opts Handlebars helper arguments
   * @return {Object}      a hash with fn, inverse and args
  ###
  utils.getHandlebarsFuncs = (opts) ->
    lastArg = _(opts).last()
    args = if lastArg.fn then _.initial(opts) else opts
    {
      fn: lastArg.fn
      inverse: lastArg.inverse
      args
    }

  utils
