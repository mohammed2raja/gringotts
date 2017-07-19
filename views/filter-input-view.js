(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, CollectionView, DropdownItemView, DropdownView, FilterInputItemView, FilterInputView, View, isLeaf, utils;
    Chaplin = require('chaplin');
    utils = require('lib/utils');
    View = require('views/base/view');
    CollectionView = require('views/base/collection-view');
    isLeaf = function(model) {
      return model.get('children') == null;
    };
    DropdownItemView = (function(superClass) {
      extend(DropdownItemView, superClass);

      function DropdownItemView() {
        return DropdownItemView.__super__.constructor.apply(this, arguments);
      }

      DropdownItemView.prototype.template = 'filter-input/list-item';

      DropdownItemView.prototype.noWrap = true;

      DropdownItemView.prototype.render = function() {
        DropdownItemView.__super__.render.apply(this, arguments);
        if (isLeaf(this.model)) {
          return this.$el.addClass('leaf');
        }
      };

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

      FilterInputView.prototype.className = 'form-control filter-input';

      FilterInputView.prototype.listSelector = '.filter-items-container';

      FilterInputView.prototype.loadingSelector = ".list-item" + FilterInputView.prototype.loadingSelector;

      FilterInputView.prototype.fallbackSelector = null;

      FilterInputView.prototype.errorSelector = ".list-item" + FilterInputView.prototype.errorSelector;

      FilterInputView.prototype.itemView = FilterInputItemView;

      FilterInputView.prototype.listen = {
        'add collection': function() {
          return this.updateButtonsState();
        },
        'remove collection': function() {
          return this.updateButtonsState();
        },
        'reset collection': function() {
          return this.updateButtonsState();
        }
      };

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
        'keydown .dropdown-groups': function(e) {
          return this.onDropdownGroupItemKeypress(e);
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
        var cl;
        if (options == null) {
          options = {};
        }
        FilterInputView.__super__.initialize.apply(this, arguments);
        this.$el.removeClass(cl = this.$el.attr('class')).addClass(this.className + " " + cl);
        this.placeholder = this.$el.data('placeholder') || options.placeholder;
        this.disabled = (this.$el.data('disabled') != null) || options.disabled;
        if (this.groupSource == null) {
          this.groupSource = new Chaplin.Collection();
        }
        if (this.itemSource == null) {
          this.itemSource = new Chaplin.Collection();
        }
        return this.filterDebounced = _.debounce(this.filterDropdownItems, 100);
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
        this.subview('dropdown-items', new DropdownView({
          el: this.$('.dropdown-items'),
          collection: this.itemSource
        }));
        return this.updateButtonsState();
      };

      FilterInputView.prototype.updateButtonsState = function() {
        return this.$('.remove-all-button').toggle(this.collection.length > 0);
      };

      FilterInputView.prototype.onWhitespaceClick = function(e) {
        var $target;
        $target = $(e.target);
        if ($target.hasClass('filter-items-container') || $target.hasClass('dropdown-control')) {
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
        var item;
        if (e.which === utils.keys.UP) {
          e.preventDefault();
          return this.visibleListItems().last().focus();
        } else if (e.which === utils.keys.DOWN) {
          e.preventDefault();
          return this.visibleListItems().first().focus();
        } else if (e.which === utils.keys.ENTER) {
          e.preventDefault();
          if (this.query() !== '' && (item = _.first(this.visibleListItems()))) {
            this["continue"] = true;
            return item.click();
          } else {
            return this.openDropdowns();
          }
        } else if (!this.selectedGroup && e.which === utils.keys.ESC) {
          e.preventDefault();
          return this.closeDropdowns();
        } else if (!this.selectedGroup && this.query() === '' && e.which === utils.keys.DELETE) {
          e.preventDefault();
          return this.collection.pop();
        } else if (this.selectedGroup && (e.which === utils.keys.ESC || (this.query() === '' && e.which === utils.keys.DELETE))) {
          e.preventDefault();
          this.setSelectedGroup(void 0);
          return this.activateDropdown('groups');
        } else if (/[\w\s]/.test(String.fromCharCode(e.which))) {
          return this.openDropdowns();
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
          this.$el.removeClass('focus');
          return this.resetInput();
        }
      };

      FilterInputView.prototype.onDropdownGroupItemClick = function(e) {
        var group, query;
        e.preventDefault();
        group = _.first(this.subview('dropdown-groups').modelsFrom(e.currentTarget));
        if (!isLeaf(group)) {
          return this.setSelectedGroup(group);
        } else if (query = this.query()) {
          return this.addSelectedItem(group, new Chaplin.Model({
            id: query,
            name: query
          }));
        }
      };

      FilterInputView.prototype.onDropdownItemClick = function(e) {
        var item;
        e.preventDefault();
        item = _.first(this.subview('dropdown-items').modelsFrom(e.currentTarget));
        return this.addSelectedItem(this.selectedGroup, item);
      };

      FilterInputView.prototype.onDropdownGroupItemKeypress = function(e) {
        var ref;
        if ((ref = e.which) === utils.keys.ENTER) {
          return this["continue"] = true;
        }
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
          return this.openDropdowns();
        } else {
          return this.maybeContinue();
        }
      };

      FilterInputView.prototype.onItemsDropdownHidden = function() {
        this.setSelectedGroup(void 0);
        this.activateDropdown('groups');
        return this.maybeContinue();
      };

      FilterInputView.prototype.query = function() {
        return this.$('input').val();
      };

      FilterInputView.prototype.openDropdowns = function() {
        this.$('.dropdown').addClass('open');
        return this.$('input').focus();
      };

      FilterInputView.prototype.closeDropdowns = function() {
        return this.$('.dropdown').removeClass('open');
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
        return group.get('children').filter((function(_this) {
          return function(groupItem) {
            return !_this.collection.any(function(item) {
              return item.id === groupItem.id;
            });
          };
        })(this));
      };

      FilterInputView.prototype.addSelectedItem = function(group, item) {
        var selectedItem;
        if (!(item && group)) {
          return;
        }
        selectedItem = item.clone();
        selectedItem.set({
          groupId: group.id,
          groupName: group.get('name')
        });
        if (group.get('singular')) {
          this.collection.remove(this.collection.filter({
            groupId: group.id
          }));
        }
        return this.collection.add(selectedItem);
      };

      FilterInputView.prototype.maybeContinue = function() {
        if (!this["continue"]) {
          return;
        }
        this.openDropdowns();
        return delete this["continue"];
      };

      FilterInputView.prototype.resetInput = function() {
        this.$('input').val('');
        return this.filterDropdownItems();
      };

      FilterInputView.prototype.filterDropdownItems = function() {
        var dropdown, filter, inGroups, names, query, regexp;
        if (this.disposed) {
          return;
        }
        inGroups = this.activeDropdown() === 'groups';
        if (query = this.query()) {
          regexp = (function() {
            try {
              return new RegExp(query, 'i');
            } catch (undefined) {}
          })();
          filter = function(item) {
            return (inGroups && isLeaf(item)) || (regexp != null ? regexp.test(item.get('name')) : void 0);
          };
        } else {
          filter = null;
        }
        if ((this.previousQuery || '') !== query) {
          dropdown = this.subview("dropdown-" + (this.activeDropdown()));
          dropdown.filter(filter);
          names = 'li' + (inGroups ? ':not(.leaf)' : '') + ' .item-name';
          dropdown.find(names).each(function(i, el) {
            var $el;
            return ($el = $(el)).html($el.text().replace(regexp, '<i>$&</i>'));
          });
          if (inGroups) {
            dropdown.find('li.leaf .item-note').each(function(i, el) {
              return $(el).text(query);
            });
          }
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
