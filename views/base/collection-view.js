(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(function(require) {
    var Chaplin, CollectionView, ErrorHandling, ServiceErrorReady, StringTemplatable, utils;
    Chaplin = require('chaplin');
    utils = require('lib/utils');
    StringTemplatable = require('../../mixins/views/string-templatable');
    ServiceErrorReady = require('../../mixins/views/service-error-ready');
    ErrorHandling = require('../../mixins/views/error-handling');
    return CollectionView = (function(superClass) {
      extend(CollectionView, superClass);

      function CollectionView() {
        return CollectionView.__super__.constructor.apply(this, arguments);
      }

      CollectionView.prototype.loadingSelector = '.loading';

      CollectionView.prototype.fallbackSelector = '.empty';

      CollectionView.prototype.useCssAnimation = true;

      CollectionView.prototype.animationStartClass = 'fade';

      CollectionView.prototype.animationEndClass = 'in';

      CollectionView.prototype.modelsFrom = function(rows) {
        var itemViews, models;
        rows = rows.length ? rows : [rows];
        itemViews = _.values(this.getItemViews());
        return models = _.filter(itemViews, function(v) {
          var ref;
          return ref = v.el, indexOf.call(rows, ref) >= 0;
        }).map(function(v) {
          return v.model;
        });
      };

      CollectionView.prototype.rowsFrom = function(models) {
        var itemViews, rows;
        models = models.length ? models : [models];
        itemViews = _.values(this.getItemViews());
        return rows = _.filter(itemViews, function(v) {
          var ref;
          return ref = v.model, indexOf.call(models, ref) >= 0;
        }).map(function(v) {
          return v.el;
        });
      };

      return CollectionView;

    })(utils.mix(Chaplin.CollectionView)["with"](StringTemplatable, ServiceErrorReady, ErrorHandling));
  });

}).call(this);
