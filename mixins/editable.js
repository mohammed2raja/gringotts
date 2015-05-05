(function() {
  define(function(require, exports) {
    var DEFAULTS, checkInput, cleanEl, convertNumber, makeEditable, setupEditable, updateLink, _;
    _ = require('underscore');
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
      opts.$field.removeClass(opts.errorClass).removeAttr('contenteditable').off('.gringottsEditable');
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
    makeEditable = function(opts) {
      opts.attribute = opts.$field.data('edit');
      opts.original = opts.model.get(opts.attribute);
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
    checkInput = function(opts) {
      var attrs, errorExists;
      opts.value = opts.$field.text();
      (attrs = {})[opts.attribute] = opts.value;
      errorExists = opts.model.validationError = opts.model.validate(attrs);
      if (errorExists) {
        opts.$field.text(opts.original).focus().addClass(opts.errorClass);
        document.execCommand('selectAll', false, null);
        if (opts.error) {
          return opts.error.call(this, errorExists, opts);
        }
      } else {
        cleanEl.call(this, opts);
        if (opts.original !== opts.value) {
          opts.href = opts.$field.attr('href') || '';
          opts.value = convertNumber(opts.value);
          if (opts.success) {
            opts.success.call(this, opts);
          }
          if (opts.href) {
            return updateLink(opts);
          }
        }
      }
    };
    setupEditable = function(clickTarget, field, opts) {
      if (opts == null) {
        opts = {};
      }
      return this.delegate('click', clickTarget, function(evt) {
        evt.preventDefault();
        _.defaults(opts, DEFAULTS);
        opts.$field = this.$(field);
        opts.model = this.model;
        return this.makeEditable(opts);
      });
    };
    return exports = function() {
      this.setupEditable = setupEditable;
      this.makeEditable = makeEditable;
      return this;
    };
  });

}).call(this);
