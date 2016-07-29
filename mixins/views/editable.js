(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var DEFAULTS, checkInput, cleanEl, convertNumber, helper, updateLink;
    helper = require('../helper');
    DEFAULTS = {
      errorClass: 'error-input'
    };
    convertNumber = function(attr) {
      var convertNum;
      convertNum = parseInt(attr, 10);
      if (convertNum === +attr) {
        return convertNum;
      } else {
        return attr;
      }
    };
    cleanEl = function(opts) {
      opts.$field.removeClass(opts.errorClass).removeAttr('contenteditable').off('.gringottsEditable').removeAttr('data-toggle').removeAttr('title').removeAttr('data-original-title').tooltip('destroy');
      if (opts.clean) {
        opts.clean.call(this, opts);
      }
      return opts.$field;
    };
    updateLink = function(opts) {
      if (/^(mailto|tel):/.test(opts.href)) {
        return opts.$field.attr('href', opts.href.replace(opts.original, opts.value));
      } else if (opts.value.indexOf('http') === 0) {
        return opts.$field.attr('href', opts.value);
      } else {
        return opts.$field.attr('href', "//" + opts.value);
      }
    };
    checkInput = function(opts) {
      var attrs, errorExists;
      opts.value = opts.$field.text();
      (attrs = {})[opts.attribute] = opts.value;
      errorExists = opts.model.validationError = opts.model.validate(attrs);
      if (errorExists) {
        opts.$field.focus().addClass(opts.errorClass);
        if (_.isString(errorExists[opts.attribute])) {
          opts.$field.attr('data-toggle', 'tooltip').attr('title', errorExists[opts.attribute]);
          opts.$field.tooltip('show').data('bs.tooltip').tip().addClass('error-tooltip');
        }
        document.execCommand('selectAll', false, null);
        if (opts.error) {
          return opts.error.call(this, errorExists, opts);
        }
      } else {
        cleanEl.call(this, opts);
        opts.value = convertNumber(opts.value);
        if (opts.original !== opts.value) {
          opts.href = opts.$field.attr('href') || '';
          if (opts.success) {
            opts.success.call(this, opts);
          }
          if (opts.href) {
            return updateLink(opts);
          }
        }
      }
    };
    return function(superclass) {
      var Editable;
      return Editable = (function(superClass) {
        extend(Editable, superClass);

        function Editable() {
          return Editable.__super__.constructor.apply(this, arguments);
        }

        Editable.prototype.initialize = function() {
          helper.assertViewOrCollectionView(this);
          return Editable.__super__.initialize.apply(this, arguments);
        };

        Editable.prototype.makeEditable = function(opts) {
          if ($('[data-edit][contenteditable]').length) {
            return;
          }
          opts.attribute = opts.$field.data('edit');
          opts.original = opts.model.get(opts.attribute) || '';
          opts.$field.attr('contenteditable', true).focus().on('keydown.gringottsEditable', (function(_this) {
            return function(evt) {
              var keyCode;
              keyCode = evt.keyCode;
              if (keyCode === 13) {
                evt.preventDefault();
                return checkInput.call(_this, opts);
              } else if (keyCode === 27) {
                opts.model.validationError = null;
                return cleanEl.call(_this, opts).text(opts.original);
              }
            };
          })(this)).on('blur.gringottsEditable', (function(_this) {
            return function() {
              return checkInput.call(_this, opts);
            };
          })(this)).on('paste.gringottsEditable', function(evt) {
            var text;
            evt.preventDefault();
            text = evt.originalEvent.clipboardData.getData('text/plain');
            return document.execCommand('insertHTML', false, text);
          });
          return document.execCommand('selectAll', false, null);
        };

        Editable.prototype.setupEditable = function(clickTarget, field, opts) {
          if (opts == null) {
            opts = {};
          }
          return this.delegate('click', clickTarget, function(evt) {
            evt.preventDefault();
            _.defaults(opts, DEFAULTS);
            opts.$field = this.$(field);
            opts.model || (opts.model = this.model);
            return this.makeEditable(opts);
          });
        };

        return Editable;

      })(superclass);
    };
  });

}).call(this);
