handlebars = require 'handlebars'
utils = require 'lib/utils'

# Output a link to an email address with the address as the text
module.exports = (email) ->
  email = handlebars.Utils.escapeExpression email
  html = utils.tagBuilder 'a', email, href: "mailto:#{email}"
  new handlebars.SafeString html
