(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, helper;
    Chaplin = require('chaplin');
    helper = require('../../lib/mixin-helper');

    /**
     * Adds state model, that is a data source for state bindings.
     * Useful to distinguish data bindings that target default model,
     * and UI state bindings that target a special independent state model.
     * @param  {Backbone.View} superclass
     */
    return function(superclass) {
      return helper.apply(superclass, function(superclass) {
        var StateBindable;
        return StateBindable = (function(superClass) {
          extend(StateBindable, superClass);

          function StateBindable() {
            return StateBindable.__super__.constructor.apply(this, arguments);
          }

          helper.setTypeName(StateBindable.prototype, 'StateBindable');

          StateBindable.prototype.listen = {
            'syncStateChange model': function() {
              return this.state.set({
                syncState: this.model.syncState()
              });
            },
            'syncStateChange collection': function() {
              return this.state.set({
                syncState: this.collection.syncState()
              });
            }
          };


          /**
           * Initial state of UI, that passed to state model.
           * The value could be either an object or a function.
           * @type {Object|Function}
           */

          StateBindable.prototype.initialState = null;


          /**
           * A state model that servers as data source for state bindings.
           * @type {Backbone.Model}
           */

          StateBindable.prototype.state = null;


          /**
           * UI state bindings to describe interactive UI with stickit bindings.
           * The value could be either an object or a function.
           * @type {Object|Function}
           */

          StateBindable.prototype.stateBindings = null;

          StateBindable.prototype.initialize = function() {
            var attrs, ref, ref1, syncState;
            helper.assertViewOrCollectionView(this);
            StateBindable.__super__.initialize.apply(this, arguments);
            attrs = _.result(this, 'initialState') || {};
            syncState = ((ref = this.model) != null ? typeof ref.syncState === "function" ? ref.syncState() : void 0 : void 0) || ((ref1 = this.collection) != null ? typeof ref1.syncState === "function" ? ref1.syncState() : void 0 : void 0);
            return this.state = new Chaplin.Model(_.defaults(attrs, {
              syncState: syncState
            }));
          };

          StateBindable.prototype.render = function() {
            StateBindable.__super__.render.apply(this, arguments);
            if (this.state && this.stateBindings) {
              return this.addBinding(this.state, _.result(this, 'stateBindings'));
            }
          };

          StateBindable.prototype.dispose = function() {
            StateBindable.__super__.dispose.apply(this, arguments);
            return this.state.dispose();
          };

          return StateBindable;

        })(superclass);
      });
    };
  });

}).call(this);
