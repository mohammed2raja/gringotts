(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, CollectionView, Handlebars, advice, convenienceClass, errorToggleView, stringTemplate;
    Chaplin = require('chaplin');
    Handlebars = require('handlebars');
    advice = require('../../mixins/advice');
    stringTemplate = require('../../mixins/string-template');
    convenienceClass = require('../../mixins/convenience-class');
    errorToggleView = require('../../mixins/error-toggle-view');

    /**
     * @param {object} sortableTableHeaders - Headers for the table.
     * @param {string} template
     */
    return CollectionView = (function(superClass) {
      extend(CollectionView, superClass);

      function CollectionView() {
        return CollectionView.__super__.constructor.apply(this, arguments);
      }

      advice.call(CollectionView.prototype);

      stringTemplate.call(CollectionView.prototype);

      convenienceClass.call(CollectionView.prototype);

      errorToggleView.call(CollectionView.prototype);

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

      CollectionView.prototype.optionNames = Chaplin.CollectionView.prototype.optionNames.concat(['template', 'sortableTableHeaders', 'routeName', 'routeParams']);

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
        return _.transform(this.sortableTableHeaders, function(result, v, k) {
          var nextOrder, order;
          order = k === state.sort_by ? state.order : '';
          nextOrder = order === 'desc' ? 'asc' : order === 'asc' ? 'desc' : this.collection.DEFAULTS.order;
          result[k] = {
            viewId: this.cid,
            attr: k,
            text: v,
            order: order,
            routeName: this.routeName,
            routeParams: this.routeParams,
            nextState: this.collection.getState({
              order: nextOrder,
              sort_by: k
            })
          };
          return result;
        }, {}, this);
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

    })(Chaplin.CollectionView);
  });

}).call(this);
