(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    return function(superclass) {
      var SafeSyncCallback;
      return SafeSyncCallback = (function(superClass) {
        extend(SafeSyncCallback, superClass);

        function SafeSyncCallback() {
          return SafeSyncCallback.__super__.constructor.apply(this, arguments);
        }

        SafeSyncCallback.prototype.sync = function() {
          this.safeSyncCallback.apply(this, arguments);
          return this.safeDeferred(SafeSyncCallback.__super__.sync.apply(this, arguments));
        };

        SafeSyncCallback.prototype.safeSyncCallback = function(method, model, options) {
          if (!options) {
            return;
          }
          return _.each(['success', 'error', 'complete'], (function(_this) {
            return function(cb) {
              var callback, ctx;
              callback = options[cb];
              if (callback) {
                ctx = options.context || _this;
                return options[cb] = function() {
                  if (!_this.disposed) {
                    return callback.apply(ctx, arguments);
                  }
                };
              }
            };
          })(this));
        };

        SafeSyncCallback.prototype.safeDeferred = function($xhr) {
          var deferred, filter;
          if (!$xhr) {
            return;
          }
          filter = (function(_this) {
            return function() {
              if (_this.disposed) {
                $xhr.errorHandled = true;
                return $.Deferred();
              } else {
                return $xhr;
              }
            };
          })(this);
          deferred = $xhr.then(filter, filter, filter).promise();
          deferred.abort = function() {
            return $xhr.abort();
          };
          return deferred;
        };

        return SafeSyncCallback;

      })(superclass);
    };
  });

}).call(this);
