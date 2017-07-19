(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, Collection, FilterSelection, utils;
    Chaplin = require('chaplin');
    utils = require('lib/utils');
    Collection = require('models/base/collection');

    /**
     * A generic collection that can be used as a selected filters collection
     * source of the FilterInputView component.
     */
    return FilterSelection = (function(superClass) {
      extend(FilterSelection, superClass);

      function FilterSelection() {
        return FilterSelection.__super__.constructor.apply(this, arguments);
      }


      /**
       * Add selected filters from JSON object and all filter groups.
       * @param  {Object}     obj
       * @param  {Collection} filterGroups
       */

      FilterSelection.prototype.fromObject = function(obj, filterGroups) {
        var result;
        result = [];
        _.forOwn(obj, function(filterIds, groupId) {
          var children, filterGroup, filters, selection;
          if (!(filterGroup = filterGroups.findWhere({
            id: groupId
          }))) {
            return;
          }
          filterIds = [].concat(filterIds);
          if (children = filterGroup.get('children')) {
            filters = children.filter(function(f) {
              return _.includes(filterIds, f.id);
            });
          } else {
            filters = _.map(filterIds, function(id) {
              return new Chaplin.Model({
                id: id,
                name: id
              });
            });
          }
          selection = filters.map(function(f) {
            var selected;
            (selected = f.clone()).set({
              groupId: groupId,
              groupName: filterGroup.get('name')
            });
            return selected;
          });
          return result.push.apply(result, selection);
        });
        return this.set(result);
      };


      /**
       * Generates JSON object from all selected filters.
       * @return {Object}
       */

      FilterSelection.prototype.toObject = function(opts) {
        var result;
        if (opts == null) {
          opts = {};
        }
        _.defaults(opts, {
          compress: true
        });
        return result = _(this.toJSON()).groupBy('groupId').mapValues(function(filters) {
          var ids;
          ids = _.map(filters, 'id');
          if (opts.compress) {
            return utils.compress(ids);
          } else {
            return ids;
          }
        }).value();
      };

      return FilterSelection;

    })(Collection);
  });

}).call(this);
