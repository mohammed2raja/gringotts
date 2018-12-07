import Chaplin from 'chaplin'
import moment from 'moment'
import join from 'url-join'
import deadDeferred from './dead-deferred'
import MixinBuilder from './mixin-builder'

###*
  * Keyboard Keys Constants
###
export keys =
  DELETE: 8
  ENTER: 13
  ESC: 27
  UP: 38
  DOWN: 40

export openURL = (path) ->
  window.open path

export getLocation = ->
  window.location

export setLocation = (path) ->
  window.location = path

export reloadLocation = ->
  window.location.reload()

###*
  * A wrapper over url-join utility. Removes all falsey arguments before join.
###
export urlJoin = ->
  join.apply this, _.map _.compact(arguments), _.toString

# Returns a string representation of an HTML node of type `tagName` wrapping
# `content` with HTML attributes `attrs`.
export tagBuilder = (tagName, content, attrs, escape = yes) ->
  tag = $ "<#{tagName}>"
  if escape
    # `.text()` escapes the string it's given which we want
    tag.text content
  else
    tag.html content
  tag.attr(attrs) if attrs
  tag[0].outerHTML

export parseJSON = (str) ->
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

export toBrowserDate = (date) ->
  moment(date).format 'YYYY-MM-DD' if date

export toServerDate = (date) ->
  moment(date).toISOString() if date

###*
  * Processes hbs helper arguments and extracts funcs and vars.
  * @param  {Object} opts Handlebars helper arguments.
  * @return {Object}      A hash with fn, inverse and args.
###
export getHandlebarsFuncs = (opts) ->
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
export mix = (superclass) -> new MixinBuilder superclass

###*
  * Loops current JS call stack until condition is true.
###
export waitUntil = (options) ->
  tick = ->
    _.defer ->
      if options.condition() then options.then() else tick()
  tick()

###*
  * Chains handlers into an abortable promise and still keeps it abortable.
###
export abortable = (promise, handlers = {}) ->
  return unless promise
  result = promise
    .progress handlers.progress or handlers.all
    .then handlers.then or handlers.all
    .catch handlers.catch or handlers.all
  if promise.abort
    result.abort = ->
      promise.abort() # compatibility with ajax deferred
      result
  result

###*
  * Filters deferred callbacks and cancels the chain if model is disposed.
###
export disposable = (promise, disposed) ->
  abortable promise, all: ->
    # find a promise to return, if not available take first argument
    result = _.find(arguments, (a) -> a?.then) or _.head arguments
    if disposed() then deadDeferred.create() else result

###*
  * Remove one GET param by name from the string URL.
  * @param  {String} url    The target URL string.
  * @param  {String} param  One param to remove.
  * @return {String}        The result URL without some params.
###
export excludeUrlParam = (url, param) ->
  url
    ?.replace new RegExp("\\b#{param}(\=[^&]*)?(&|$)"), ''
    .replace /&$/, ''

###*
  * Remove one or many GET param by names from the string URL.
  * @param  {String}       url    The target URL string.
  * @param  {String|Array} param  One or many params to remove.
  * @return {String}              The result URL without some params.
###
export excludeUrlParams = (url, params) ->
  if _.isArray params
    _.reduce params, (result, p) ->
      excludeUrlParam result, p
    , url
  else if _.isString params
    excludeUrlParam url, params

###*
* If obj is a single element array, the element is returned. Otherwise the
* obj itself will be returned.
###
export compress = (obj) ->
  if _.isArray(obj) and obj.length is 1 then obj[0] else obj

###*
 * A workaround utility for acessing parent prototype property
 * members. Assuming that CoffeeScript v2 uses `super` only as function.
###
export superValue = (obj, property, filter = _.isObject) ->
  chain = Chaplin.utils.getPrototypeChain obj
  _(chain).map(property).filter(filter).first()
