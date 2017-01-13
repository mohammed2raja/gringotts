(function() {
  define(function(require) {
    var Chaplin, MixinBuilder, abortable, deadDeferred, disposable, join, moment;
    Chaplin = require('chaplin');
    moment = require('moment');
    join = require('url_join');
    deadDeferred = require('./dead-deferred');
    MixinBuilder = require('./mixin-builder');

    /**
     * Chains handlers into an abortable promise and still keeps it abortable.
     */
    abortable = function(promise, handlers) {
      var result;
      if (handlers == null) {
        handlers = {};
      }
      if (!promise) {
        return;
      }
      result = promise.progress(handlers.progress || handlers.all).then(handlers.then || handlers.all)["catch"](handlers["catch"] || handlers.all);
      if (promise.abort) {
        result.abort = function() {
          promise.abort();
          return result;
        };
      }
      return result;
    };

    /**
     * Filters deferred callbacks and cancels the chain if model is disposed.
     */
    disposable = function(promise, disposed) {
      return abortable(promise, {
        all: function() {
          var result;
          result = _.find(arguments, function(a) {
            return a != null ? a.then : void 0;
          }) || _.first(arguments);
          if (disposed()) {
            return deadDeferred.create();
          } else {
            return result;
          }
        }
      });
    };
    return _.extend({}, Chaplin.utils, {

      /**
       * Keyboard Keys Constants
       */
      keys: {
        DELETE: 8,
        ENTER: 13,
        ESC: 27,
        UP: 38,
        DOWN: 40
      },
      openURL: function(path) {
        return window.open(path);
      },
      getLocation: function() {
        return window.location;
      },
      setLocation: function(path) {
        return window.location = path;
      },
      reloadLocation: function() {
        return window.location.reload();
      },

      /**
       * A wrapper over url join utility.
       */
      urlJoin: function() {
        var url;
        url = join.apply(this, arguments);
        return url.replace(/^(\/\/)/, '/');
      },
      tagBuilder: function(tagName, content, attrs, escape) {
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
      },
      parseJSON: function(str) {
        var error, error1, ref, result;
        result = false;
        try {
          result = JSON.parse(str);
        } catch (error1) {
          error = error1;
          if (typeof str === 'undefined') {
            str = 'undefined';
          } else if (str.length === 0) {
            str = 'Empty string';
          }
          if ((ref = window.Raven) != null) {
            ref.captureException(error, {
              tags: {
                str: str
              }
            });
          }
        }
        return result;
      },
      toBrowserDate: function(date) {
        if (date) {
          return moment(date).format('YYYY-MM-DD');
        }
      },
      toServerDate: function(date) {
        if (date) {
          return moment(date).toISOString();
        }
      },

      /**
       * Processes hbs helper arguments and extracts funcs and vars.
       * @param  {Object} opts Handlebars helper arguments.
       * @return {Object}      A hash with fn, inverse and args.
       */
      getHandlebarsFuncs: function(opts) {
        var args, lastArg;
        lastArg = _(opts).last();
        args = lastArg.fn ? _.initial(opts) : opts;
        return {
          fn: lastArg.fn,
          inverse: lastArg.inverse,
          args: args
        };
      },

      /**
       * An alias method to MixinBuilder.
       * @param  {Type} superclass A target type to mixin into.
       * @return {Type}            A result type with all mixins applied.
       */
      mix: function(superclass) {
        return new MixinBuilder(superclass);
      },
      waitUntil: function(options) {
        var tick;
        tick = function() {
          return _.defer(function() {
            if (options.condition()) {
              return options.then();
            } else {
              return tick();
            }
          });
        };
        return tick();
      },
      abortable: abortable,
      disposable: disposable
    });
  });

}).call(this);
