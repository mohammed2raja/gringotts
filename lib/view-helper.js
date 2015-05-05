(function() {
  define(function(require) {
    var $, Handlebars, moment, utils;
    Handlebars = require('handlebars');
    moment = require('moment');
    utils = require('./utils');
    $ = require('jquery');
    Handlebars.registerHelper('url', function(routeName, params, third) {
      var query;
      if (arguments.length === 4) {
        query = third;
      }
      return utils.reverse(routeName, [params], query);
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
