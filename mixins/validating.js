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
    backboneValidation.configure({
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


        /**
         * Regex patterns that may be used in template data to
         * fill DOM elements pattern property.
         * @type {Object}
         */

        Validating.prototype.patterns = backboneValidation.patterns;

        Validating.prototype.initialize = function() {
          Validating.__super__.initialize.apply(this, arguments);
          if (this.model) {
            return this.bindModel(this.model);
          }
        };

        Validating.prototype.getTemplateData = function() {
          return _.extend(Validating.__super__.getTemplateData.apply(this, arguments), {
            regex: _.mapValues(this.patterns, function(re) {
              return re.source;
            })
          });
        };

        Validating.prototype.dispose = function() {
          if (this.model) {
            this.unbindModel(this.model);
          }
          return Validating.__super__.dispose.apply(this, arguments);
        };

        Validating.prototype.bindModel = function(model) {
          if (model.associatedViews) {
            if (model.associatedViews.indexOf(this) < 0) {
              return model.associatedViews.push(this);
            }
          } else {
            return model.associatedViews = [this];
          }
        };

        Validating.prototype.unbindModel = function(model) {
          if (model.associatedViews) {
            return model.associatedViews = _.without(model.associatedViews, this);
          }
        };

        return Validating;

      })(superclass);
    };
  });

}).call(this);
