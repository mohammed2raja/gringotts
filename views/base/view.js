(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Automatable, Chaplin, StringTemplate, View;
    Chaplin = require('chaplin');
    Automatable = require('../../mixins/automatable');
    StringTemplate = require('../../mixins/string-template');
    return View = (function(superClass) {
      extend(View, superClass);

      function View() {
        return View.__super__.constructor.apply(this, arguments);
      }

      View.prototype.autoRender = true;

      View.prototype.optionNames = View.prototype.optionNames.concat(['template']);

      return View;

    })(Automatable(StringTemplate(Chaplin.View)));
  });

}).call(this);
