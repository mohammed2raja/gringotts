define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  Collection = require 'models/base/collection'

  ###*
   * A generic collection that can be used as a selected filters collection
   * source of the FilterInputView component.
  ###
  class FilterSelection extends Collection
    modelId: (attrs) ->
      "#{attrs['groupId']}-#{attrs['id']}"

    ###*
     * Add selected filters from JSON object.
     * @param  {Object}     obj
     * @param  {Collection} filterGroups - to reconstuct group information
    ###
    fromObject: (obj, opts={}) ->
      {filterGroups} = opts
      return unless filterGroups
      result = []
      _.forOwn obj, (filterIds, groupId) ->
        return unless filterGroup = filterGroups.findWhere id: groupId
        filterIds = [].concat filterIds
        if children = filterGroup.get 'children'
          filters = children.filter (f) -> _.includes filterIds, f.id
        else
          filters = _.map filterIds, (id) -> new Chaplin.Model {id, name: id}
        selection = filters.map (f) ->
          (selected = f.clone()).set _.extend {
            groupId
            groupName: filterGroup.get 'name'
          }, if required = filterGroup.get 'required' then {required}
          selected
        result.push.apply result, selection
      @set result

    ###*
     * Generates JSON object from all selected filters.
     * @param  {Bool} compress - if yes, single item array values will be
     * converted to just those values.
     * @param  {Collection} filterGroups - filter group information for
     * potential usage during serialization logic.
     * @return {Object}
    ###
    toObject: (opts={}) ->
      {compress} = _.defaults opts, compress: yes
      result = _(@toJSON()).groupBy 'groupId'
        .mapValues (filters) ->
          ids = _.map filters, 'id'
          if compress then utils.compress ids else ids
        .value()
