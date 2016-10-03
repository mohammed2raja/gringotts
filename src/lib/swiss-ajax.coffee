define (require) ->
  Backbone = require 'backbone'
  backboneAjax = Backbone.ajax

  ajaxForArray = ->
    options = _.first arguments
    $.when.apply $, options.url.map (url) ->
      backboneAjax _.merge _.omit(options, ['url', 'success']), {url}
    .done ->
      resp =
        if options.url.length > 1
          _.slice(arguments).map (arg) -> _.first arg
        else
          _.first arguments
      options.success? resp

  ajaxForHash = ->
    options = _.first arguments
    pairs = _.transform options.url, (memo, url, key) ->
      memo.push {key, url}
    , []
    $.when.apply $, pairs.map (pair) ->
      backboneAjax _.merge _.omit(options, ['url', 'success']), url: pair.url
    .done ->
      resp = _.slice(arguments).reduce (memo, arg, i) ->
        memo[pairs[i].key] = _.first arg
        memo
      , {}
      options.success? resp

  ajax = ->
    options = _.first arguments
    if _.isArray options.url
      ajaxForArray.apply $, arguments
    else if _.isObject(options.url) and not _.isFunction options.url
      ajaxForHash.apply $, arguments
    else
      backboneAjax.apply $, arguments

  ###*
   * Swiss army knife for ajax. Will create a set of parallel ajax calls for
   * every url that's passed in Array, Hash or String. As soon as all calls are
   * finished the done and options.success callback will be invoked with
   * the results.
   * It's recommended to override Model's parse method to handle multiple
   * response data results.
   * This is useful for models that need to fetch parts of data from different
   * API endpoints.
   * The options.error() will be called as many times as many errors happened
   * during parallel ajax requests execution.
  ###
  {backboneAjax, ajaxForArray, ajaxForHash, ajax}
