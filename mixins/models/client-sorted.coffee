import helper from '../../lib/mixin-helper'

###*
  * Adds clint-side sorting support to a Collection.
  * @param  {Collection} base superclass
###
export default (superclass) -> class ClientSorted extends superclass
  DEFAULTS: _.defaults {}, @::DEFAULTS,
    order: 'desc'
    sort_by: undefined

  initialize: ->
    helper.assertCollection this
    super arguments...
    @query ?= {}

  testSortAB: (modelA, modelB, sortOrder, sortAttr, sortValue, nextCompare) ->
    order = sortOrder.call this
    attr = sortAttr.call this
    orderSwitch = if order is 'desc' then 1 else -1
    a = sortValue.call this, @getSortAttrValue(modelA, attr), modelA
    b = sortValue.call this, @getSortAttrValue(modelB, attr), modelB
    if a is b
      return nextCompare?.call(this, modelA, modelB) or 0
    if a > b then -1 * orderSwitch else 1 * orderSwitch

  comparator: (modelA, modelB) ->
    @testSortAB modelA, modelB, @sortOrder, \
      @sortAttr, @sortValue, @secondComparator

  ###*
    * Comparator for secondary sort by
  ###
  secondComparator: (modelA, modelB) ->
    @testSortAB modelA, modelB, @secondSortOrder, \
      @secondSortAttr, @secondSortValue, @thirdComparator

  ###*
    * Comparator for tertiary sort by
  ###
  thirdComparator: (modelA, modelB) ->
    @testSortAB modelA, modelB, @thirdSortOrder, \
      @thirdSortAttr, @thirdSortValue

  ###*
    * Returns sort order. Optional, defaults to descending.
  ###
  sortOrder: ->
    @query.order or @DEFAULTS.order

  ###*
    * Returns attribute that we are sorting by.
  ###
  sortAttr: ->
    @query.sort_by or @DEFAULTS.sort_by

  ###*
    * Returns value to sort by.
  ###
  sortValue: (value) -> value

  ###*
    * Returns secondary sort order.
  ###
  secondSortOrder: -> 'desc'

  ###*
    * Returns secondary attribute that we are sorting by.
  ###
  secondSortAttr: ->

  ###*
    * Returns value to sort secondary attribute by.
  ###
  secondSortValue: (value) -> value

  ###*
    * Returns tertiary sort order.
  ###
  thirdSortOrder: -> 'desc'

  ###*
    * Returns tertiary attribute that we are sorting by.
  ###
  thirdSortAttr: ->

  ###*
    * Returns value to sort tertiary attribute by.
  ###
  thirdSortValue: (value) -> value

  getSortAttrValue: (model, attr) ->
    model.get?(attr) or model[attr]
