import handlebars from 'handlebars/runtime'

# Output element for use with font icon classes.
# If name has couple of classes then the last one is used as icon name.
# We use generic class name with a specific one for cleaner stylesheets.
# You can specify a second argument to add additional attributes.
# If the second argument is a hash it will add the keys/values as attrs.
# If it is a string it will add it as a class.
#
# **e.g.** `{{icon 'awesome' 'extra-classy'}}`
export default (name, attrs = {}) ->
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
