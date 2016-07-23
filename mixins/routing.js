(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {

    /**
     * Add two properties routeName and routeParams to a View or CollectionView
     * that are used for passing context for Chaplin routing utils.
     * @param  {View|CollectionView} superclass Only views
     */
    return function(superclass) {
      var Routing;
      return Routing = (function(superClass) {
        extend(Routing, superClass);

        function Routing() {
          return Routing.__super__.constructor.apply(this, arguments);
        }

        Routing.prototype.optionNames = Routing.prototype.optionNames.concat(['routeName', 'routeParams']);

        Routing.prototype.initItemView = function() {
          var view;
          view = Routing.__super__.initItemView.apply(this, arguments);
          view.routeName = this.routeName;
          view.routeParams = this.routeParams;
          return view;
        };

        Routing.prototype.getTemplateData = function() {
          return _.extend(Routing.__super__.getTemplateData.apply(this, arguments), {
            routeName: this.routeName,
            routeParams: this.routeParams
          });
        };

        return Routing;

      })(superclass);
    };
  });

}).call(this);
