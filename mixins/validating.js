(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var backboneValidation, stickit;
    backboneValidation = require('backbone_validation');
    stickit = require('stickit');
    stickit.addHandler({
      selector: '*',
      setOptions: {
        validate: true
      }
    });

    /**
     * Turn on validation for view UI upon model attributes update.
     * Add/remove bootstrap validation classes for elements with errors.
     * @param  {Backbone.View} superclass
     */
    return function(superclass) {
      var Validating;
      return Validating = (function(superClass) {
        extend(Validating, superClass);

        function Validating() {
          return Validating.__super__.constructor.apply(this, arguments);
        }

        Validating.prototype.patterns = backboneValidation.patterns;

        Validating.prototype.validationConfig = {
          forceUpdate: true,
          valid: function(view, attr, selector) {
            var $el, $group;
            $el = view.$("[name=" + attr + "]");
            return $group = $el.closest('.form-group').removeClass('has-error').find('.help-block').html('').addClass('hidden');
          },
          invalid: function(view, attr, error, selector) {
            var $el, $group;
            $el = view.$("[name=" + attr + "]");
            return $group = $el.closest('.form-group').addClass('has-error').find('.help-block').html(error).removeClass('hidden');
          }
        };

        Validating.prototype.initialize = function() {
          Validating.__super__.initialize.apply(this, arguments);
          return backboneValidation.bind(this, this.validationConfig);
        };

        Validating.prototype.getTemplateData = function() {
          return _.extend(Validating.__super__.getTemplateData.apply(this, arguments), {
            regex: _.mapValues(this.patterns, function(re) {
              return re.source;
            })
          });
        };

        return Validating;

      })(superclass);
    };
  });

}).call(this);
