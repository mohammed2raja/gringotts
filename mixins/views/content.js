(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper;
    helper = require('../../lib/mixin-helper');
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var Content;
        return Content = (function(superClass) {
          extend(Content, superClass);

          function Content() {
            return Content.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(Content.prototype, 'Content');

          Content.prototype.container = '#content';

          Content.prototype.containerMethod = 'prepend';

          Content.prototype.initialize = function() {
            helper.assertViewOrCollectionView(this);
            return Content.__super__.initialize.apply(this, arguments);
          };

          return Content;

        })(superclass);
      });
    };
  });

}).call(this);
