(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {

    /**
     * Adds on an automation id for QE purposes.
     * Based on the template property.
     */
    return function(superclass) {
      var Automatable;
      return Automatable = (function(superClass) {
        extend(Automatable, superClass);

        function Automatable() {
          return Automatable.__super__.constructor.apply(this, arguments);
        }

        Automatable.prototype.render = function() {
          var id;
          if (this.template && (id = this.template.replace(/\//g, '-'))) {
            this.$el.attr('qe-id', id);
          }
          return Automatable.__super__.render.apply(this, arguments);
        };

        return Automatable;

      })(superclass);
    };
  });

}).call(this);
