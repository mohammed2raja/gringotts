(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, CollectionView, DropdownItemView, DropdownView, FilterInputItemView, FilterInputView, View, utils;
    Chaplin = require('chaplin');
    utils = require('lib/utils');
    View = require('views/base/view');
    CollectionView = require('views/base/collection-view');
    DropdownItemView = (function(superClass) {
      extend(DropdownItemView, superClass);

      function DropdownItemView() {
        return DropdownItemView.__super__.constructor.apply(this, arguments);
      }

      DropdownItemView.prototype.template = 'filter-input/list-item';

      DropdownItemView.prototype.noWrap = true;

      return DropdownItemView;

    })(View);
    DropdownView = (function(superClass) {
      extend(DropdownView, superClass);

      function DropdownView() {
        return DropdownView.__super__.constructor.apply(this, arguments);
      }

      DropdownView.prototype.itemView = DropdownItemView;

      DropdownView.prototype.getTemplateFunction = function() {};

      return DropdownView;

    })(CollectionView);
    FilterInputItemView = (function(superClass) {
      extend(FilterInputItemView, superClass);

      function FilterInputItemView() {
        return FilterInputItemView.__super__.constructor.apply(this, arguments);
      }

      FilterInputItemView.prototype.template = 'filter-input/item';

      FilterInputItemView.prototype.noWrap = true;

      return FilterInputItemView;

    })(View);
    return FilterInputView = (function(superClass) {
      extend(FilterInputView, superClass);

      function FilterInputView() {
        return FilterInputView.__super__.constructor.apply(this, arguments);
      }

      FilterInputView.prototype.optionNames = FilterInputView.prototype.optionNames.concat(['groupSource']);

      FilterInputView.prototype.template = 'filter-input/view';

      FilterInputView.prototype.className = 'filter-input form-control';

      FilterInputView.prototype.loadingSelector = ".list-item" + FilterInputView.prototype.loadingSelector;

      FilterInputView.prototype.fallbackSelector = null;

      FilterInputView.prototype.errorSelector = ".list-item" + FilterInputView.prototype.errorSelector;

      FilterInputView.prototype.itemView = FilterInputItemView;

      FilterInputView.prototype.events = {
        'click': function(e) {
          return this.onWhitespaceClick(e);
        },
        'click .remove-button': function(e) {
          return this.onItemRemoveClick(e);
        },
        'click .remove-all-button': function(e) {
          return this.onRemoveAllClick(e);
        },
        'click input': function(e) {
          return this.onInputClick(e);
        },
        'keydown input': function(e) {
          return this.onInputKeydown(e);
        },
        'keyup input': function(e) {
          return this.onInputKeyup(e);
        },
        'focus input': function(e) {
          return this.onInputFocus(e);
        },
        'blur input': function(e) {
          return this.onInputBlur(e);
        },
        'click .dropdown-groups li': function(e) {
          return this.onDropdownGroupItemClick(e);
        },
        'click .dropdown-items li': function(e) {
          return this.onDropdownItemClick(e);
        },
        'keydown .dropdown-items': function(e) {
          return this.onDropdownItemKeypress(e);
        },
        'show.bs.dropdown .dropdown': function(e) {
          return this.onDropdownShow(e);
        },
        'hide.bs.dropdown .dropdown': function(e) {
          return this.onDropdownHide(e);
        },
        'hidden.bs.dropdown .dropdown': function(e) {
          return this.onDropdownHidden(e);
        }
      };

      FilterInputView.prototype.initialize = function(options) {
        if (options == null) {
          options = {};
        }
        FilterInputView.__super__.initialize.apply(this, arguments);
        this.$el.addClass(this.className);
        this.placeholder = this.$el.data('placeholder') || options.placeholder;
        this.disabled = (this.$el.data('disabled') != null) || options.disabled;
        if (this.groupSource == null) {
          this.groupSource = new Chaplin.Collection();
        }
        if (this.itemSource == null) {
          this.itemSource = new Chaplin.Collection();
        }
        return this.filterDebounced = _.debounce(this.filterDropdownItems, 300);
      };

      FilterInputView.prototype.getTemplateData = function() {
        return {
          placeholder: this.placeholder,
          disabled: this.disabled,
          loadingText: (typeof I18n !== "undefined" && I18n !== null ? I18n.t('loading.text') : void 0) || 'Loading...',
          emptyText: (typeof I18n !== "undefined" && I18n !== null ? I18n.t('filter_input.empty') : void 0) || 'There are no filters available',
          errorText: (typeof I18n !== "undefined" && I18n !== null ? I18n.t('filter_input.error') : void 0) || 'There was a problem while loading filters'
        };
      };

      FilterInputView.prototype.render = function() {
        FilterInputView.__super__.render.apply(this, arguments);
        this.subview('dropdown-groups', new DropdownView({
          el: this.$('.dropdown-groups'),
          collection: this.groupSource
        }));
        return this.subview('dropdown-items', new DropdownView({
          el: this.$('.dropdown-items'),
          collection: this.itemSource
        }));
      };

      FilterInputView.prototype.onWhitespaceClick = function(e) {
        var $target;
        $target = $(e.target);
        if ($target.hasClass('form-control') || $target.hasClass('dropdown-control')) {
          e.stopPropagation();
          return this.openDropdowns();
        }
      };

      FilterInputView.prototype.onItemRemoveClick = function(e) {
        return this.collection.remove(this.modelsFrom($(e.currentTarget).parent('.selected-item')));
      };

      FilterInputView.prototype.onRemoveAllClick = function(e) {
        return this.collection.reset();
      };

      FilterInputView.prototype.onInputClick = function(e) {
        if (this.$('.dropdown').hasClass('open')) {
          return e.stopPropagation();
        }
      };

      FilterInputView.prototype.onInputKeydown = function(e) {
        var items;
        if (e.which === utils.keys.UP) {
          e.preventDefault();
          return this.visibleListItems().last().focus();
        } else if (e.which === utils.keys.DOWN) {
          e.preventDefault();
          return this.visibleListItems().first().focus();
        } else if (e.which === utils.keys.ENTER) {
          e.preventDefault();
          if ((items = this.visibleListItems()).length === 1) {
            this["continue"] = true;
            return items[0].click();
          } else {
            return this.openDropdowns();
          }
        } else if (this.selectedGroup && (e.which === utils.keys.ESC || (this.$('input').val() === '' && e.which === utils.keys.DELETE))) {
          e.preventDefault();
          this.setSelectedGroup(void 0);
          return this.activateDropdown('groups');
        }
      };

      FilterInputView.prototype.onInputKeyup = function(e) {
        return this.filterDebounced();
      };

      FilterInputView.prototype.onInputFocus = function(e) {
        return this.$el.addClass('focus');
      };

      FilterInputView.prototype.onInputBlur = function(e) {
        if (!this.$('.dropdown').hasClass('open')) {
          return this.$el.removeClass('focus');
        }
      };

      FilterInputView.prototype.onDropdownGroupItemClick = function(e) {
        var group;
        e.preventDefault();
        group = _.first(this.subview('dropdown-groups').modelsFrom(e.currentTarget));
        return this.setSelectedGroup(group);
      };

      FilterInputView.prototype.onDropdownItemClick = function(e) {
        var item;
        e.preventDefault();
        item = _.first(this.subview('dropdown-items').modelsFrom(e.currentTarget));
        return this.addSelectedItem(item);
      };

      FilterInputView.prototype.onDropdownItemKeypress = function(e) {
        var ref;
        if ((ref = e.which) === utils.keys.ENTER || ref === utils.keys.ESC) {
          return this["continue"] = true;
        }
      };

      FilterInputView.prototype.onDropdownShow = function(e) {
        return this.$el.addClass('focus');
      };

      FilterInputView.prototype.onDropdownHide = function(e) {
        return this.$el.removeClass('focus');
      };

      FilterInputView.prototype.onDropdownHidden = function(e) {
        this.resetInput();
        if (this.activeDropdown() === 'groups') {
          return this.onGroupsDropdownHidden();
        } else if (this.activeDropdown() === 'items') {
          return this.onItemsDropdownHidden();
        }
      };

      FilterInputView.prototype.onGroupsDropdownHidden = function() {
        if (this.selectedGroup) {
          this.activateDropdown('items');
          this.openDropdowns();
          return this.$('input').focus();
        }
      };

      FilterInputView.prototype.onItemsDropdownHidden = function() {
        this.setSelectedGroup(void 0);
        this.activateDropdown('groups');
        if (this["continue"]) {
          this.openDropdowns();
          this.$('input').focus();
          return delete this["continue"];
        }
      };

      FilterInputView.prototype.openDropdowns = function() {
        this.$('.dropdown').addClass('open');
        return this.$el.addClass('focus');
      };

      FilterInputView.prototype.visibleListItems = function() {
        return this.$('.dropdown-menu:not(.hidden) a:visible');
      };

      FilterInputView.prototype.activeDropdown = function() {
        if (this.$('.dropdown-groups').hasClass('hidden')) {
          return 'items';
        }
        if (this.$('.dropdown-items').hasClass('hidden')) {
          return 'groups';
        }
      };

      FilterInputView.prototype.activateDropdown = function(target) {
        var another;
        another = target === 'groups' ? 'items' : 'groups';
        this.$(".dropdown-" + target).toggleClass('hidden', false);
        return this.$(".dropdown-" + another).toggleClass('hidden', true);
      };

      FilterInputView.prototype.setSelectedGroup = function(group) {
        this.selectedGroup = group;
        this.$('.selected-group').text((group != null ? group.get('name') : void 0) || '');
        this.itemSource.reset(this.groupItems(group));
        return this.subview('dropdown-items').toggleFallback();
      };

      FilterInputView.prototype.groupItems = function(group) {
        if (!group) {
          return [];
        }
        return _.filter(group.get('children').models, (function(_this) {
          return function(listItem) {
            return !_.any(_this.collection.models, function(item) {
              return item.id === listItem.id;
            });
          };
        })(this));
      };

      FilterInputView.prototype.addSelectedItem = function(item) {
        var selectedItem;
        if (!(item && this.selectedGroup)) {
          return;
        }
        selectedItem = item.clone();
        selectedItem.set({
          groupId: this.selectedGroup.get('id'),
          groupName: this.selectedGroup.get('name')
        });
        return this.collection.add(selectedItem);
      };

      FilterInputView.prototype.resetInput = function() {
        this.$('input').val('');
        return this.filterDropdownItems();
      };

      FilterInputView.prototype.filterDropdownItems = function() {
        var dropdown, filter, query, regexp;
        if (this.disposed) {
          return;
        }
        if (query = this.$('input').val()) {
          regexp = new RegExp(query, 'gi');
          filter = function(item) {
            return regexp.test(item.get('name'));
          };
        } else {
          filter = null;
        }
        if (this.previousQuery !== query) {
          dropdown = this.subview("dropdown-" + (this.activeDropdown()));
          dropdown.filter(filter);
          dropdown.toggleFallback();
          return this.previousQuery = query;
        }
      };

      FilterInputView.prototype.dispose = function() {
        delete this.groupSource;
        delete this.itemSource;
        delete this.selectedGroup;
        return FilterInputView.__super__.dispose.apply(this, arguments);
      };

      return FilterInputView;

    })(CollectionView);
  });

}).call(this);
