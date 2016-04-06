(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Automatable, Chaplin, CollectionView, Handlebars, ServiceErrorReady, StringTemplate, utils;
    Chaplin = require('chaplin');
    Handlebars = require('handlebars');
    utils = require('../../lib/utils');
    StringTemplate = require('../../mixins/string-template');
    Automatable = require('../../mixins/automatable');
    ServiceErrorReady = require('../../mixins/service-error-ready');

    /**
     * @param {object} sortableTableHeaders - Headers for the table.
     */
    return CollectionView = (function(superClass) {
      extend(CollectionView, superClass);

      function CollectionView() {
        return CollectionView.__super__.constructor.apply(this, arguments);
      }

      CollectionView.prototype.listen = {
        'request collection': function() {
          return this.renderControls();
        },
        'sync collection': function() {
          return this.renderControls();
        },
        'sort collection': function() {
          return this.renderControls();
        }
      };

      CollectionView.prototype.optionNames = CollectionView.prototype.optionNames.concat(['template', 'sortableTableHeaders', 'routeName', 'routeParams']);

      CollectionView.prototype.loadingSelector = '.loading';

      CollectionView.prototype.fallbackSelector = '.empty';

      CollectionView.prototype.sortingPartial = 'sortTableHeader';

      CollectionView.prototype._highlightColumns = function() {
        var idx, state;
        state = this.collection.getState({}, true);
        idx = this.$("th[data-sort=" + state.sort_by + "]").index();
        return this.$(this.listSelector + " " + this.itemView.prototype.tagName + " td").removeClass('highlighted').filter(":nth-child(" + (idx + 1) + ")").not('[colspan]').addClass('highlighted');
      };

      CollectionView.prototype._getSortInfo = function() {
        var state;
        if (!this.sortableTableHeaders) {
          return null;
        }
        state = this.collection.getState({}, true);
        if (!state.sort_by) {
          throw new Error('Please define a sort_by attribute within DEFAULTS');
        }
        return _.transform(this.sortableTableHeaders, (function(_this) {
          return function(result, title, column) {
            var nextOrder, order;
            order = column === state.sort_by ? state.order : '';
            nextOrder = order === 'asc' ? 'desc' : 'asc';
            result[column] = {
              viewId: _this.cid,
              attr: column,
              text: title,
              order: order,
              routeName: _this.routeName,
              routeParams: _this.routeParams,
              nextState: _this.collection.getState({
                order: nextOrder,
                sort_by: column
              })
            };
            return result;
          };
        })(this), {});
      };

      CollectionView.prototype.getTemplateData = function() {
        var sortInfo;
        sortInfo = this._getSortInfo();
        if (sortInfo) {
          return _.extend(CollectionView.__super__.getTemplateData.apply(this, arguments), {
            sortInfo: sortInfo
          });
        } else {
          return CollectionView.__super__.getTemplateData.apply(this, arguments);
        }
      };

      CollectionView.prototype.renderAllItems = function() {
        CollectionView.__super__.renderAllItems.apply(this, arguments);
        if (this.sortableTableHeaders) {
          return this._highlightColumns();
        }
      };

      CollectionView.prototype.renderControls = function() {
        var sortInfo, template;
        sortInfo = this._getSortInfo();
        template = Handlebars.partials[this.sortingPartial];
        if (!(sortInfo && template)) {
          return;
        }
        return this.$(".sorting-control." + this.cid).each(function(i, el) {
          var $el, attr;
          $el = $(el);
          attr = $el.attr('data-sort');
          return $el.replaceWith(template({
            sortInfo: sortInfo,
            attr: attr
          }));
        });
      };

      return CollectionView;

    })(utils.mix(Chaplin.CollectionView)["with"](StringTemplate, Automatable, ServiceErrorReady));
  });

}).call(this);
