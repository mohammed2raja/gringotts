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
  Handlebars.registerHelper 'url', (routeName, params, third) ->
    # Account for the Handlebars context argument that gets append to every call
    query = third if arguments.length is 4
    utils.reverse routeName, [params], query

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
  #
  # **e.g.** `ll, h:mm:ss a`
  Handlebars.registerHelper 'dateFormat', (time, format) ->
    moment(time).format(format)

  # Output a link to an email address with the address as the text
  Handlebars.registerHelper 'mailTo', (email) ->
    email = Handlebars.Utils.escapeExpression email
    html = utils.tagBuilder 'a', email, href: "mailto:#{email}"
    new Handlebars.SafeString html
