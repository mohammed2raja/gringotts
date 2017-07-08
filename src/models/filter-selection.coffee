define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
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
        return unless filterGroup = filterGroups.findWhere id: groupId
        filterIds = [].concat filterIds
        if children = filterGroup.get 'children'
          filters = children.filter (f) -> _.includes filterIds, f.id
        else
          filters = _.map filterIds, (id) -> new Chaplin.Model {id, name: id}
        selection = filters.map (f) ->
          (selected = f.clone()).set {
            groupId
            groupName: filterGroup.get 'name'
          }
          selected
        result.push.apply result, selection
      @set result

    ###*
     * Generates JSON object from all selected filters.
     * @return {Object}
    ###
    toObject: (opts={}) ->
      _.defaults opts, compress: yes
      result = _(@toJSON()).groupBy 'groupId'
        .mapValues (filters) ->
          ids = _.map filters, 'id'
          if opts.compress then utils.compress ids else ids
        .value()
