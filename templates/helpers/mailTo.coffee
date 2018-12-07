import handlebars from 'handlebars/runtime'
import {tagBuilder} from '../../lib/utils'

# Output a link to an email address with the address as the text
export default (email) ->
  email = handlebars.Utils.escapeExpression email
  html = tagBuilder 'a', email, href: "mailto:#{email}"
  new handlebars.SafeString html
