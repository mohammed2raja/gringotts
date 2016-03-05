(function() {
  var slice = [].slice;

  define(function(require) {
    var $, Handlebars, moment, utils;
    Handlebars = require('handlebars');
    moment = require('moment');
    utils = require('./utils');
    $ = require('jquery');
    Handlebars.registerHelper('url', function() {
      var criteria, hbsOpts, options, opts, params, query;
      opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      options = _.initial(opts);
      hbsOpts = _.last(opts);
      criteria = options[0];
      params = _.isObject(options[1]) ? options[1] : _.isArray(options[1]) ? options[1] : options[1] ? [options[1]] : null;
      query = options[2];
      return utils.reverse(criteria, params, query || hbsOpts.hash);
    });
    Handlebars.registerHelper('icon', function(name, attrs) {
      var icon;
      if (attrs == null) {
        attrs = {};
      }
      icon = $('<span>');
      if (typeof attrs === 'string') {
        attrs = {
          "class": attrs
        };
      }
      icon.attr(attrs);
      icon.addClass("icon " + name + "-font");
      return new Handlebars.SafeString(icon[0].outerHTML);
    });
    Handlebars.registerHelper('dateFormat', function(time, format) {
      return moment(time).format(format);
    });
    Handlebars.registerHelper('mailTo', function(email) {
      var html;
      email = Handlebars.Utils.escapeExpression(email);
      html = utils.tagBuilder('a', email, {
        href: "mailto:" + email
      });
      return new Handlebars.SafeString(html);
    });

    /**
     * A simple helper to concat strings.
     * @param {array} opts A list of string to be combined.
     */
    Handlebars.registerHelper('concat', function() {
      var opts, result;
      opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return result = _(opts).initial().reduce(function(result, part) {
        return result + part;
      }, '');
    });

    /**
     * Helper which accepts two or more booleans and returns
     * template block executions.
     */
    Handlebars.registerHelper('or', function() {
      var args, fn, inverse, opts, ref;
      opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      ref = utils.getHandlebarsFuncs(opts), fn = ref.fn, inverse = ref.inverse, args = ref.args;
      if (_.isEmpty(_.compact(args))) {
        if (inverse) {
          return inverse(this);
        } else {
          return false;
        }
      } else if (fn) {
        return fn(this);
      } else {
        return true;
      }
    });
    Handlebars.registerHelper('and', function() {
      var args, fn, inverse, opts, ref;
      opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      ref = utils.getHandlebarsFuncs(opts), fn = ref.fn, inverse = ref.inverse, args = ref.args;
      if (_.every(args)) {
        if (fn) {
          return fn(this);
        } else {
          return true;
        }
      } else if (inverse) {
        return inverse(this);
      } else {
        return false;
      }
    });
    return Handlebars.registerHelper('not', function() {
      var args, fn, inverse, opts, ref;
      opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      ref = utils.getHandlebarsFuncs(opts), fn = ref.fn, inverse = ref.inverse, args = ref.args;
      if (_.isEmpty(_.compact(args))) {
        if (fn) {
          return fn(this);
        } else {
          return true;
        }
      } else if (inverse) {
        return inverse(this);
      } else {
        return false;
      }
    });
  });

}).call(this);
