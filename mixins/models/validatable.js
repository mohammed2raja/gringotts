(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var BROWSER_DATE, backboneValidation, helper, moment;
    moment = require('moment');
    backboneValidation = require('backbone_validation');
    helper = require('../../lib/mixin-helper');
    backboneValidation.configure({
      labelFormatter: 'label'
    });
    _.extend(backboneValidation.patterns, {
      name: /^((?!<\\?.*>).)+/,
      email: /^[^@]+@[^@]+\.[^@]+$/,
      domain: /[a-z0-9.\-]+\.[a-zA-Z]{2,}/,
      url: /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/,
      guid: /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/
    });
    _.extend(backboneValidation.messages, {
      name: '{0} must be a valid name',
      guid: '{0} must be a valid guid',
      date: '{0} must be a valid date',
      domain: '{0} must be a valid domain'
    });
    BROWSER_DATE = ['MM/DD/YYYY', 'YYYY-MM-DD'];

    /**
     * Applies backbone.validation mixin to a Model.
     * Adds a validateDate function.
     * @param  {Backbone.Model} superclass
     */
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var Validatable;
        return Validatable = (function(superClass) {
          extend(Validatable, superClass);

          function Validatable() {
            return Validatable.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(Validatable.prototype, 'Validatable');

          _.extend(Validatable.prototype, _.extend({}, backboneValidation.mixin, {
            isValid: function(option) {
              return backboneValidation.mixin.isValid.apply(this, [option || true]);
            },
            validate: function() {
              var error;
              error = backboneValidation.mixin.validate.apply(this, arguments);
              this.validationError = error || null;
              return error;
            }
          }));

          Validatable.prototype.initialize = function() {
            helper.assertModel(this);
            return Validatable.__super__.initialize.apply(this, arguments);
          };

          Validatable.prototype.validateDate = function(value, attr) {
            if (value && !moment(value, BROWSER_DATE).isValid()) {
              return backboneValidation.messages.date.replace('{0}', backboneValidation.labelFormatters.label(attr, this));
            }
          };

          return Validatable;

        })(superclass);
      });
    };
  });

}).call(this);
