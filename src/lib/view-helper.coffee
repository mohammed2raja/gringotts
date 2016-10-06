define (require) ->
  handlebars = require 'handlebars'
  moment = require 'moment'
  utils = require './utils'
  $ = require 'jquery'

  # General view helpers
  # http://handlebarsjs.com/#helpers

  # Get Chaplin-declared named routes.
  #
  # **e.g.** `{{#url "like" "105"}}{{/url}}`
  handlebars.registerHelper 'url', (opts...) ->
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
  # If name has couple of classes then the last one is used as icon name.
  # We use generic class name with a specific one for cleaner stylesheets.
  # You can specify a second argument to add additional attributes.
  # If the second argument is a hash it will add the keys/values as attrs.
  # If it is a string it will add it as a class.
  #
  # **e.g.** `{{icon 'awesome' 'extra-classy'}}`
  handlebars.registerHelper 'icon', (name, attrs={}) ->
    return unless name
    icon = $('<span>')
    if typeof attrs is 'string'
      attrs = class: attrs
    icon.attr attrs
    names = _.compact name?.split ' '
    classes = _.initial(names).join ' '
    iconName = _.last names
    icon.addClass(classes).addClass "icon icon-#{iconName}"
    new handlebars.SafeString icon[0].outerHTML

  # Format time by passing in the format string.
  # The default input parsing format is ISO.
  #
  # **e.g.** `ll, h:mm:ss a`
  handlebars.registerHelper 'dateFormat', (opts...) ->
    [time, format, inputFormat] = _.initial opts
    hbsOpts = _.last opts
    moment(time, inputFormat or moment.ISO_8601).format(format)

  # Output a link to an email address with the address as the text
  handlebars.registerHelper 'mailTo', (email) ->
    email = handlebars.Utils.escapeExpression email
    html = utils.tagBuilder 'a', email, href: "mailto:#{email}"
    new handlebars.SafeString html

  ###*
   * A simple helper to concat strings.
   * @param {array} opts A list of string to be combined.
  ###
  handlebars.registerHelper 'concat', (opts...) ->
    result = _(opts).initial().reduce (result, part) ->
      result + part
    , ''

  ###*
   * Helper which accepts two or more booleans and returns
   * template block executions.
  ###
  handlebars.registerHelper 'or', (opts...) ->
    {fn, inverse, args} = utils.getHandlebarsFuncs opts
    if _.isEmpty _.compact(args)
      if inverse then inverse this else false
    else if fn then fn this else true

  handlebars.registerHelper 'and', (opts...) ->
    {fn, inverse, args} = utils.getHandlebarsFuncs opts
    if _.every args
      if fn then fn this else true
    else if inverse then inverse this else false

  handlebars.registerHelper 'not', (opts...) ->
    {fn, inverse, args} = utils.getHandlebarsFuncs opts
    if _.isEmpty _.compact(args)
      if fn then fn this else true
    else if inverse then inverse this else false

  ###*
   * Compares two values and renders matching template like #if
  ###
  handlebars.registerHelper 'ifequal', (lvalue, rvalue, options) ->
    if arguments.length < 2
      throw new Error('Handlebars Helper equal needs 2 parameters')
    {fn, inverse} = utils.getHandlebarsFuncs [options or {}]
    if lvalue is rvalue
      if fn then fn this else true
    else if inverse then inverse this else false

  ###*
   * Compares two values and renders matching template like #unless
  ###
  handlebars.registerHelper 'unlessEqual', (lvalue, rvalue, options) ->
    if arguments.length < 2
      throw new Error('Handlebars Helper equal needs 2 parameters')
    {fn, inverse} = utils.getHandlebarsFuncs [options or {}]
    if lvalue isnt rvalue
      if fn then fn this else true
    else if inverse then inverse this else false

  ###*
   * Returns list of arguments as array. Useful for {{url (array a b c)}}
   * @param  {Array} opts... Input arguments
   * @return {Array}         Array of arguments
  ###
  handlebars.registerHelper 'array', (opts...) ->
    _.initial opts

  ###*
   * Returns hash of arguments as object. Useful for {{url (object a=b c=d)}}
   * @param  {Object} opts... Input hash
   * @return {Object}         Object from arguments
  ###
  handlebars.registerHelper 'object', (opts...) ->
    _.last(opts).hash
