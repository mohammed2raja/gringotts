import Chaplin from 'chaplin'

# Get Chaplin-declared named routes.
#
# **e.g.** `{{#url "like" "105"}}{{/url}}`
export default (opts...) ->
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
  Chaplin.utils.reverse criteria, params, query or hbsOpts.hash
