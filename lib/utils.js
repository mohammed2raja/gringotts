(function() {
  define(function(require) {
    var $, Backbone, Chaplin, utils;
    Backbone = require('backbone');
    Chaplin = require('chaplin');
    $ = Backbone.$;
    utils = Chaplin.utils.beget(Chaplin.utils);
    utils.tagBuilder = function(tagName, content, attrs, escape) {
      var tag;
      if (escape == null) {
        escape = true;
      }
      tag = $("<" + tagName + ">");
      if (escape) {
        tag.text(content);
      } else {
        tag.html(content);
      }
      if (attrs) {
        tag.attr(attrs);
      }
      return tag[0].outerHTML;
    };
    utils.isEnumerable = function(obj, property) {
      return Object.keys(obj).indexOf(property) > -1;
    };

    /**
     * Generates a convenient css class name for QE purposes.
     * Assumingly it's being used for every view in the application.
     * @param  {String} className Existing view's class name.
     * @param  {String} template  View's template path.
     * @return {String}           A newly generated class name using template.
     */
    utils.convenienceClass = function(className, template) {
      var convenient, original;
      if (template) {
        convenient = template.replace(/\//g, '-');
        original = className ? " " + className : '';
        className = "" + convenient + original;
      }
      return className;
    };
    utils.parseJSON = function(str) {
      var error, result;
      result = false;
      try {
        result = JSON.parse(str);
      } catch (_error) {
        error = _error;
        if (typeof str === 'undefined') {
          str = 'undefined';
        } else if (str.length === 0) {
          str = 'Empty string';
        }
        if (typeof Raven !== "undefined" && Raven !== null) {
          Raven.captureException(error, {
            tags: {
              str: str
            }
          });
        }
      }
      return result;
    };

    /**
     * Processes hbs helper arguments and extracts funcs and vars
     * @param  {Object} opts Handlebars helper arguments
     * @return {Object}      a hash with fn, inverse and args
     */
    utils.getHandlebarsFuncs = function(opts) {
      var args, lastArg;
      lastArg = _(opts).last();
      args = lastArg.fn ? _.initial(opts) : opts;
      return {
        fn: lastArg.fn,
        inverse: lastArg.inverse,
        args: args
      };
    };
    return utils;
  });

}).call(this);
