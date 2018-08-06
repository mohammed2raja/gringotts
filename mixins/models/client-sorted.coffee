import utils from 'lib/utils'
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

  comparator: (modelA, modelB) ->
    order = @sortOrder()
    attr = @sortAttr()
    orderSwitch = if order is 'desc' then 1 else -1
    a = @sortValue @getSortAttrValue(modelA, attr), modelA
    b = @sortValue @getSortAttrValue(modelB, attr), modelB
    if a is b
      return @secondComparator modelA, modelB
    if a > b then -1 * orderSwitch else 1 * orderSwitch

  ###*
    * Comparator for secondary sort by
  ###
  secondComparator: (modelA, modelB) ->
    order = @secondSortOrder()
    attr = @secondSortAttr()
    orderSwitch = if order is 'desc' then 1 else -1
    return 0 unless attr
    a = @secondSortValue @getSortAttrValue(modelA, attr), modelA
    b = @secondSortValue @getSortAttrValue(modelB, attr), modelB
    0 if a is b
    if a > b then -1 * orderSwitch else 1 * orderSwitch

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

  getSortAttrValue: (model, attr) ->
    model.get?(attr) or model[attr]
