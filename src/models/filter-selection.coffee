define (require) ->
  Collection = require 'models/base/collection'

  ###*
   * A generic collection that can be used as a selected filters collection
   * source of the FilterInputView component.
  ###
  class FilterSelection extends Collection
    ###*
     * Add selected filters from JSON object and all filter groups.
     * @param  {Object}     obj
     * @param  {Collection} filterGroups
    ###
    fromObject: (obj, filterGroups) ->
      result = []
      _.forOwn obj, (filterIds, groupId) ->
        filterGroup = filterGroups.findWhere id: groupId
        filters = filterGroup.get 'children'
          .filter (f) -> _.includes filterIds, f.id
        selection = filters.map (f) ->
          (selected = f.clone()).set {
            groupId
            groupName: filterGroup.get 'name'
          }
          selected
        result.push.apply result, selection
      @add result

    ###*
     * Generates JSON object from all selected filters.
     * @return {Object}
    ###
    toObject: ->
      result = _(@toJSON()).groupBy 'groupId'
        .mapValues (filters) -> _.map filters, 'id'
        .value()
