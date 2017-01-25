(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var helper;
    helper = require('../../lib/mixin-helper');
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var ExportLink;
        return ExportLink = (function(superClass) {
          extend(ExportLink, superClass);

          function ExportLink() {
            return ExportLink.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(ExportLink.prototype, 'ExportLink');

          ExportLink.prototype.initialize = function() {
            helper.assertCollectionView(this);
            return ExportLink.__super__.initialize.apply(this, arguments);
          };


          /**
           * Generates a link to export items from the collection bypassing pagination
           * parameters. The mixin should be applied to views that
           * have collection property. Collection should have getQuery() method.
           * @param  {String} baseUrl - to build export url
           * @return {String}
           */

          ExportLink.prototype.exportLink = function(baseUrl) {
            var query;
            query = _.clone(this.collection.getQuery({
              inclDefaults: true
            }));
            delete query.page;
            delete query.per_page;
            return this.collection.url(baseUrl, query);
          };

          return ExportLink;

        })(superclass);
      });
    };
  });

}).call(this);
