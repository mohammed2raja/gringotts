define (require) ->
  Handlebars = require 'handlebars'
  moment = require 'moment'
  utils = require './utils'
  $ = require 'jquery'

  # General view helpers
  # http://handlebarsjs.com/#helpers

  # Get Chaplin-declared named routes.
  #
  # **e.g.** `{{#url "like" "105"}}{{/url}}`
  Handlebars.registerHelper 'url', (opts...) ->
    # Account for the Handlebars context argument that gets append to every call
    options = _.initial opts
    hbsOpts = _.last opts
    criteria = options[0]
    params =
      if _.isObject options[1] then options[1]
      else if _.isArray options[1] then options[1]
      else if options[1] then [options[1]]
      else null
    query = options[2]
    utils.reverse criteria, params, query or hbsOpts.hash

  # Output element for use with font icon classes.
  # We use generic class name with a specific one for cleaner stylesheets.
  # You can specify a second argument to add additional attributes.
  # If the second argument is a hash it will add the keys/values as attrs.
  # If it is a string it will add it as a class.
  #
  # **e.g.** `{{icon 'awesome' 'extra-classy'}}`
  Handlebars.registerHelper 'icon', (name, attrs={}) ->
    icon = $('<span>')
    if typeof attrs is 'string'
      attrs = class: attrs
    icon.attr attrs
    icon.addClass "icon #{name}-font"
    new Handlebars.SafeString icon[0].outerHTML

  # Format time by passing in the format string.
  # The default input parsing format is ISO.
  #
  # **e.g.** `ll, h:mm:ss a`
  Handlebars.registerHelper 'dateFormat', (opts...) ->
    [time, format, inputFormat] = _.initial opts
    hbsOpts = _.last opts
    moment(time, inputFormat or moment.ISO_8601).format(format)

  # Output a link to an email address with the address as the text
  Handlebars.registerHelper 'mailTo', (email) ->
    email = Handlebars.Utils.escapeExpression email
    html = utils.tagBuilder 'a', email, href: "mailto:#{email}"
    new Handlebars.SafeString html

  ###*
   * A simple helper to concat strings.
   * @param {array} opts A list of string to be combined.
  ###
  Handlebars.registerHelper 'concat', (opts...) ->
    result = _(opts).initial().reduce (result, part) ->
      result + part
    , ''

  ###*
   * Helper which accepts two or more booleans and returns
   * template block executions.
  ###
  Handlebars.registerHelper 'or', (opts...) ->
    {fn, inverse, args} = utils.getHandlebarsFuncs opts
    if _.isEmpty _.compact(args)
      if inverse then inverse this else false
    else if fn then fn this else true

  Handlebars.registerHelper 'and', (opts...) ->
    {fn, inverse, args} = utils.getHandlebarsFuncs opts
    if _.every args
      if fn then fn this else true
    else if inverse then inverse this else false

  Handlebars.registerHelper 'not', (opts...) ->
    {fn, inverse, args} = utils.getHandlebarsFuncs opts
    if _.isEmpty _.compact(args)
      if fn then fn this else true
    else if inverse then inverse this else false

  ###*
   * Compares two values and renders matching template like #if
  ###
  Handlebars.registerHelper 'ifequal', (lvalue, rvalue, options) ->
    if arguments.length < 3
      throw new Error('Handlebars Helper equal needs 2 parameters')

    if lvalue is rvalue
      return options.fn(this)
    else
      return options.inverse(this)

  ###*
   * Compares two values and renders matching template like #unless
  ###
  Handlebars.registerHelper 'unlessEqual', (lvalue, rvalue, options) ->
    if arguments.length < 3
      throw new Error('Handlebars Helper equal needs 2 parameters')

    if lvalue isnt rvalue
      return options.fn(this)
    else
      return options.inverse(this)

  ###*
   * Retunrs list of arguments as array. Useful for {{url (array a b c)}}
   * @param  {Array} opts... Input arguments
   * @return {Array}         Array of arguments
  ###
  Handlebars.registerHelper 'array', (opts...) ->
    _.initial opts
