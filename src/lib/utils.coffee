define (require) ->
  Chaplin = require 'chaplin'
  moment = require 'moment'
  join = require 'url_join'
  MixinBuilder = require './mixin-builder'

  #coffeelint: disable=max_line_length
  # Typically, a project will create their own `utils` file/object to beget
  # `Chaplin.utils` and add their own methods. Feel free to map this file to
  # a more suitable path in `require.config`.
  # See [Chaplin utils](https://github.com/chaplinjs/chaplin-boilerplate/blob/master/coffee/lib/coffee)
  # for an example.
  #coffeelint: enable=max_line_length
  _.extend {}, Chaplin.utils,

    ###*
     * Keyboard Keys Constants
    ###
    keys:
      DELETE: 8
      ENTER: 13
      ESC: 27
      UP: 38
      DOWN: 40

    openURL: (path) ->
      window.open path

    getLocation: ->
      window.location

    setLocation: (path) ->
      window.location = path

    reloadLocation: ->
      window.location.reload()

    ###*
     * A wrapper over url join utility.
    ###
    urlJoin: ->
      url = join.apply this, arguments
      # HACK: fix bug in url_join, where it adds '//' if first arg is empty
      url.replace /^(\/\/)/, '/'

    # Returns a string representation of an HTML node of type `tagName` wrapping
    # `content` with HTML attributes `attrs`.
    tagBuilder: (tagName, content, attrs, escape=yes) ->
      tag = $ "<#{tagName}>"
      if escape
        # `.text()` escapes the string it's given which we want
        tag.text content
      else
        tag.html content
      tag.attr(attrs) if attrs
      tag[0].outerHTML

    parseJSON: (str) ->
      result = false
      try
        result = JSON.parse str
      catch error
        # Improve tag value of falsy values.
        if typeof str is 'undefined'
          str = 'undefined'
        else if str.length is 0
          str = 'Empty string'
        window.Raven?.captureException error, tags: {str}
      result

    toBrowserDate: (date) ->
      moment(date).format 'YYYY-MM-DD' if date

    toServerDate: (date) ->
      moment(date).toISOString() if date

    ###*
     * Processes hbs helper arguments and extracts funcs and vars.
     * @param  {Object} opts Handlebars helper arguments.
     * @return {Object}      A hash with fn, inverse and args.
    ###
    getHandlebarsFuncs: (opts) ->
      lastArg = _(opts).last()
      args = if lastArg.fn then _.initial(opts) else opts
      {
        fn: lastArg.fn
        inverse: lastArg.inverse
        args
      }

    ###*
     * An alias method to MixinBuilder.
     * @param  {Type} superclass A target type to mixin into.
     * @return {Type}            A result type with all mixins applied.
    ###
    mix: (superclass) -> new MixinBuilder superclass
