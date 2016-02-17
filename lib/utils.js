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
     * Initialize SyncMachine on an object
     * @param  {Backbone.Events} obj an instinace of Model or Collection
     * @param  {Bool} listenAll to listen events from nested models
     */
    utils.initSyncMachine = function(obj, listenAll) {
      if (listenAll == null) {
        listenAll = false;
      }
      if (!obj.on) {
        throw new Error('obj must be Backbone.Events');
      }
      obj.on('request', function(model) {
        if (obj === model || listenAll) {
          return obj.beginSync();
        }
      });
      obj.on('sync', function(model) {
        if (obj === model || listenAll) {
          return obj.finishSync();
        }
      });
      return obj.on('error', function(model) {
        if (obj === model || listenAll) {
          return obj.unsync();
        }
      });
    };
    return utils;
  });

}).call(this);
