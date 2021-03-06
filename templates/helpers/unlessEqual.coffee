###*
  * Compares two values and renders matching template like #unless
###
export default (lvalue, rvalue, options = {}) ->
  if arguments.length < 2
    throw new Error('Handlebars Helper equal needs 2 parameters')
  {fn, inverse} = options
  if lvalue isnt rvalue
    if fn then fn this else true
  else if inverse then inverse this else false
