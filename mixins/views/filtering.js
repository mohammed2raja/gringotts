(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var FilterInputView, FilterSelection, Routing, helper, isPerhapsSyncedDeep;
    helper = require('../../lib/mixin-helper');
    FilterSelection = require('../../models/filter-selection');
    FilterInputView = require('../../views/filter-input-view');
    Routing = require('./routing');
    isPerhapsSyncedDeep = function(collection) {
      if (_.isFunction(collection.isSyncedDeep)) {
        return collection.isSyncedDeep();
      } else {
        return true;
      }
    };

    /**
     * Helps initialize and sync the filter selection state of the FilterInputView
     * control and the underlying CollectionView's queryable collection.
     */
    return function(superclass) {
      var Filtering;
      return Filtering = (function(superClass) {
        extend(Filtering, superClass);

        function Filtering() {
          return Filtering.__super__.constructor.apply(this, arguments);
        }

        helper.setTypeName(Filtering.prototype, 'Filtering');

        Filtering.prototype.optionNames = Filtering.prototype.optionNames.concat(['filterGroups']);

        Filtering.prototype.filterSelection = FilterSelection;

        Filtering.prototype.filteringIsActive = function() {
          return this.filterSelection && this.filterGroups;
        };

        Filtering.prototype.initialize = function() {
          helper.assertViewOrCollectionView(this);
          Filtering.__super__.initialize.apply(this, arguments);
          this.filterSelection = new this.filterSelection();
          return this.addFilterSelectionListeners();
        };

        Filtering.prototype.render = function() {
          Filtering.__super__.render.apply(this, arguments);
          if (this.filteringIsActive()) {
            this.subview('filtering-control', new FilterInputView({
              el: this.$('.filtering-control[data-filter-input]'),
              collection: this.filterSelection,
              groupSource: this.filterGroups
            }));
          }
          return this.updateFilterSelection();
        };

        Filtering.prototype.onBrowserQueryChange = function() {
          Filtering.__super__.onBrowserQueryChange.apply(this, arguments);
          return this.updateFilterSelection();
        };

        Filtering.prototype.updateFilterSelection = function() {
          if (!this.filteringIsActive()) {
            return;
          }
          if (isPerhapsSyncedDeep(this.filterGroups)) {
            return this.resetFilterSelection(this.getBrowserQuery());
          } else {
            return this.listenTo(this.filterGroups, 'syncDeep', function() {
              return this.resetFilterSelection(this.getBrowserQuery());
            });
          }
        };

        Filtering.prototype.resetFilterSelection = function(obj) {
          this.removeFilterSelectionListeners();
          this.filterSelection.fromObject(obj, {
            filterGroups: this.filterGroups
          });
          return this.addFilterSelectionListeners();
        };

        Filtering.prototype.addFilterSelectionListeners = function() {
          this.listenTo(this.filterSelection, 'update', this.onFilterSelectionUpdate);
          return this.listenTo(this.filterSelection, 'reset', this.onFilterSelectionUpdate);
        };

        Filtering.prototype.removeFilterSelectionListeners = function() {
          this.stopListening(this.filterSelection, 'update', this.onFilterSelectionUpdate);
          return this.stopListening(this.filterSelection, 'reset', this.onFilterSelectionUpdate);
        };

        Filtering.prototype.onFilterSelectionUpdate = function() {
          var query;
          query = _.defaults(this.filterSelection.toObject({
            filterGroups: this.filterGroups
          }), _.zipObject(this.filterGroups.pluck('id')));
          return this.setBrowserQuery(_.extend(query, {
            page: 1
          }));
        };

        return Filtering;

      })(Routing(superclass));
    };
  });

}).call(this);
