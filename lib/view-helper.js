(function() {
  var slice = [].slice;

  define(function(require) {
    var $, handlebars, moment, utils;
    handlebars = require('handlebars');
    moment = require('moment');
    utils = require('./utils');
    $ = require('jquery');
    handlebars.registerHelper('url', function() {
      var criteria, hbsOpts, options, opts, params, query;
      opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      options = _.initial(opts);
      hbsOpts = _.last(opts);
      criteria = options[0];
      params = _.isObject(options[1]) ? options[1] : _.isArray(options[1]) ? options[1] : options[1] ? [options[1]] : null;
      query = options[2];
      return utils.reverse(criteria, params, query || hbsOpts.hash);
    });
    handlebars.registerHelper('icon', function(name, attrs) {
      var classes, icon, iconName, names;
      if (attrs == null) {
        attrs = {};
      }
      if (!name) {
        return;
      }
      icon = $('<span>');
      if (typeof attrs === 'string') {
        attrs = {
          "class": attrs
        };
      }
      icon.attr(attrs);
      names = _.compact(name != null ? name.split(' ') : void 0);
      classes = _.initial(names).join(' ');
      iconName = _.last(names);
      icon.addClass(classes).addClass("icon icon-" + iconName);
      return new handlebars.SafeString(icon[0].outerHTML);
    });
    handlebars.registerHelper('dateFormat', function() {
      var format, hbsOpts, inputFormat, opts, ref, time;
      opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      ref = _.initial(opts), time = ref[0], format = ref[1], inputFormat = ref[2];
      if (!time) {
        return;
      }
      hbsOpts = _.last(opts);
      return moment(time, inputFormat || moment.ISO_8601).format(format);
    });
    handlebars.registerHelper('mailTo', function(email) {
      var html;
      email = handlebars.Utils.escapeExpression(email);
      html = utils.tagBuilder('a', email, {
        href: "mailto:" + email
      });
      return new handlebars.SafeString(html);
    });

    /**
     * A simple helper to concat strings.
     * @param {array} opts A list of string to be combined.
     */
    handlebars.registerHelper('concat', function() {
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
    handlebars.registerHelper('or', function() {
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
    handlebars.registerHelper('and', function() {
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
    handlebars.registerHelper('not', function() {
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

    /**
     * Compares two values and renders matching template like #if
     */
    handlebars.registerHelper('ifequal', function(lvalue, rvalue, options) {
      var fn, inverse, ref;
      if (arguments.length < 2) {
        throw new Error('Handlebars Helper equal needs 2 parameters');
      }
      ref = utils.getHandlebarsFuncs([options || {}]), fn = ref.fn, inverse = ref.inverse;
      if (lvalue === rvalue) {
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

    /**
     * Compares two values and renders matching template like #unless
     */
    handlebars.registerHelper('unlessEqual', function(lvalue, rvalue, options) {
      var fn, inverse, ref;
      if (arguments.length < 2) {
        throw new Error('Handlebars Helper equal needs 2 parameters');
      }
      ref = utils.getHandlebarsFuncs([options || {}]), fn = ref.fn, inverse = ref.inverse;
      if (lvalue !== rvalue) {
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

    /**
     * Returns list of arguments as array. Useful for {{url (array a b c)}}
     * @param  {Array} opts... Input arguments
     * @return {Array}         Array of arguments
     */
    handlebars.registerHelper('array', function() {
      var opts;
      opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return _.initial(opts);
    });

    /**
     * Returns hash of arguments as object. Useful for {{url (object a=b c=d)}}
     * @param  {Object} opts... Input hash
     * @return {Object}         Object from arguments
     */
    return handlebars.registerHelper('object', function() {
      var opts;
      opts = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return _.last(opts).hash;
    });
  });

}).call(this);
