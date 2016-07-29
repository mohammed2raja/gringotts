(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, CollectionView, ServiceErrorReady, StringTemplatable, utils;
    Chaplin = require('chaplin');
    utils = require('lib/utils');
    StringTemplatable = require('../../mixins/views/string-templatable');
    ServiceErrorReady = require('../../mixins/views/service-error-ready');
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

      return CollectionView;

    })(utils.mix(Chaplin.CollectionView)["with"](StringTemplatable, ServiceErrorReady));
  });

}).call(this);
