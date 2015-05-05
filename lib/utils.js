(function() {
  define(function(require, exports) {
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
    return exports = utils;
  });

}).call(this);
