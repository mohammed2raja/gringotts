(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var CollectionView, Handlebars, PaginatedView, utils;
    Handlebars = require('handlebars');
    utils = require('../../lib/utils');
    CollectionView = require('./collection-view');
    return PaginatedView = (function(superClass) {
      extend(PaginatedView, superClass);

      function PaginatedView() {
        return PaginatedView.__super__.constructor.apply(this, arguments);
      }

      PaginatedView.prototype.paginationPartial = 'pagination';


      /**
       * Overriding chaplin's toggleLoadingIndicator to
       * remove the collection length requirement.
       */

      PaginatedView.prototype.toggleLoadingIndicator = function() {
        var visible;
        visible = this.collection.isSyncing();
        this.$('tbody > tr').not(this.loadingSelector).not(this.fallbackSelector).not(this.errorSelector).toggle(!visible);
        return this.$loading.toggle(visible);
      };

      PaginatedView.prototype._getStats = function(min, max, info) {
        if (typeof I18n !== "undefined" && I18n !== null) {
          return I18n.t('items.total', {
            start: min,
            end: max,
            total: info.count
          });
        } else {
          return ([min, max].join('-')) + " of " + info.count;
        }
      };

      PaginatedView.prototype._getRangeString = function(page, perPage, info) {
        var max, maxItems, min;
        maxItems = info.pages * perPage;
        max = info.count === maxItems ? info.count : Math.min(info.count, page * perPage);
        min = (page - 1) * perPage + 1;
        min = Math.min(min, max);
        return this._getStats(min, max, info);
      };

      PaginatedView.prototype._getPageInfo = function() {
        var infinite, info, page, perPage, state;
        infinite = this.collection.infinite;
        state = this.collection.getState({}, {
          inclDefaults: true,
          usePrefix: false
        });
        perPage = parseInt(state.per_page);
        page = infinite ? state.page : parseInt(state.page);
        info = {
          viewId: this.cid,
          count: this.collection.count,
          page: page,
          perPage: perPage
        };
        if (infinite) {
          info.pages = 1;
          info.multiPaged = true;
          info.prev = page !== 1 ? 1 : 0;
          info.next = this.collection.nextPageId;
        } else {
          info.pages = Math.ceil(this.collection.count / perPage);
          info.multiPaged = this.collection.count > perPage;
          info.prev = page > 1 ? page - 1 : 0;
          info.next = page < info.pages ? page + 1 : 0;
          info.range = this._getRangeString(page, perPage, info);
        }
        info.nextState = info.next ? this.collection.getState({
          page: info.next
        }) : this.collection.getState();
        info.prevState = info.prev ? this.collection.getState({
          page: info.prev
        }) : this.collection.getState();
        info.routeName = this.routeName;
        info.routeParams = this.routeParams;
        return info;
      };


      /**
       * Add the pageInfo context into the view template.
       * Render using {{> pagination pageInfo}}.
       * @return {object} Context for use within the template.
       */

      PaginatedView.prototype.getTemplateData = function() {
        return _.extend(PaginatedView.__super__.getTemplateData.apply(this, arguments), {
          pageInfo: this._getPageInfo()
        });
      };

      PaginatedView.prototype.renderControls = function() {
        var pageInfo, template;
        PaginatedView.__super__.renderControls.apply(this, arguments);
        pageInfo = this._getPageInfo();
        template = Handlebars.partials[this.paginationPartial];
        if (!(pageInfo && template)) {
          return;
        }
        return this.$(".pagination-controls." + this.cid).each(function(i, el) {
          return $(el).replaceWith(template(pageInfo));
        });
      };

      return PaginatedView;

    })(CollectionView);
  });

}).call(this);
