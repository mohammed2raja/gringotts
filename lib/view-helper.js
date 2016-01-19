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
    return Handlebars.registerHelper('mailTo', function(email) {
      var html;
      email = Handlebars.Utils.escapeExpression(email);
      html = utils.tagBuilder('a', email, {
        href: "mailto:" + email
      });
      return new Handlebars.SafeString(html);
    });
  });

}).call(this);
