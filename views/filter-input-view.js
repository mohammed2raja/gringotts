(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, CollectionView, DESCRIPTION_MAX_LENGTH, DropdownItemView, DropdownView, FilterInputItemView, FilterInputView, View, handlebars, highlightMatch, isLeaf, matching, matchingChild, regExp, utils;
    Chaplin = require('chaplin');
    handlebars = require('handlebars');
    utils = require('lib/utils');
    View = require('views/base/view');
    CollectionView = require('views/base/collection-view');
    DESCRIPTION_MAX_LENGTH = 40;
    isLeaf = function(model) {
      return model.get('children') == null;
    };
    regExp = function(query, opts) {
      var mode, startsWith;
      if (opts == null) {
        opts = {};
      }
      if (!query) {
        return;
      }
      startsWith = _.defaults(opts, {
        startsWith: true
      }).startsWith;
      mode = !!parseInt(query) ? '()' : (startsWith ? '^()' : '(^|\\W)');
      try {
        return new RegExp(mode + "(" + query + ")", 'i');
      } catch (undefined) {}
    };
    matching = function(item, regexp) {
      return regexp != null ? regexp.test(item.get('name')) : void 0;
    };
    matchingChild = function(group, regexp) {
      var ref;
      return _.first(group != null ? (ref = group.get('children')) != null ? ref.filter(function(c) {
        return matching(c, regexp);
      }) : void 0 : void 0);
    };
    highlightMatch = function(text, regexp) {
      return new handlebars.SafeString(text != null ? text.replace(regexp, '$1<i>$2</i>') : void 0);
    };
    DropdownItemView = (function(superClass) {
      extend(DropdownItemView, superClass);

      DropdownItemView.prototype.template = 'filter-input/list-item';

      DropdownItemView.prototype.tagName = 'li';

      DropdownItemView.prototype.query = '';

      DropdownItemView.prototype.className = function() {
        return (this.isLeaf ? 'leaf ' : '') + 'filter-item';
      };

      function DropdownItemView(arg) {
        var model;
        model = arg.model;
        this.isLeaf = isLeaf(model);
        this.isActionItem = this.isLeaf && model.get('description');
        this.needsDescription = !this.isLeaf && !model.get('description');
        DropdownItemView.__super__.constructor.apply(this, arguments);
      }

      DropdownItemView.prototype.initialize = function() {
        DropdownItemView.__super__.initialize.apply(this, arguments);
        if (this.needsDescription) {
          return this.listenTo(this.model.get('children'), 'synced', function() {
            return this.render();
          });
        }
      };

      DropdownItemView.prototype.getTemplateData = function() {
        var data;
        data = DropdownItemView.__super__.getTemplateData.apply(this, arguments);
        if (this.needsDescription) {
          _.extend(data, {
            description: this.generateDesc()
          });
        }
        if (this.query) {
          if (this.isActionItem) {
            data.note = this.query;
          } else {
            data.name = highlightMatch(data.name, regExp(this.query));
            if (data.description) {
              data.description = highlightMatch(data.description, regExp(this.query, {
                startsWith: false
              }));
            }
          }
        }
        return data;
      };

      DropdownItemView.prototype.render = function() {
        DropdownItemView.__super__.render.apply(this, arguments);
        if (this.isActionItem) {
          return this.$el.toggleClass('disabled no-hover', this.query === '');
        }
      };

      DropdownItemView.prototype.highlight = function(query) {
        if (this.query === query) {
          return;
        }
        this.query = query;
        this.description = null;
        return this.render();
      };

      DropdownItemView.prototype.generateDesc = function() {
        var children, i, len, match, name, picks, ref, ref1, totalLength;
        if (this.description) {
          return this.description;
        }
        if ((children = this.model.get('children')).length) {
          picks = [];
          totalLength = 0;
          ref = _.compact(children.pluck('name'));
          for (i = 0, len = ref.length; i < len; i++) {
            name = ref[i];
            if (!((totalLength += name.length) <= DESCRIPTION_MAX_LENGTH)) {
              break;
            }
            picks.push(name.trim());
          }
          if (this.query) {
            match = (ref1 = matchingChild(this.model, regExp(this.query))) != null ? ref1.get('name') : void 0;
          }
          picks = _.union(picks, match ? [match] : void 0);
          return this.description = this.unionDesc(picks, children.length);
        } else {
          return (typeof I18n !== "undefined" && I18n !== null ? I18n.t('loading.text') : void 0) || 'Loading...';
        }
      };

      DropdownItemView.prototype.unionDesc = function(picks, totalCount) {
        var ellipsis;
        if (picks.length === 2 && totalCount === 2) {
          return picks.join(" " + ((typeof I18n !== "undefined" && I18n !== null ? I18n.t('labels.or') : void 0) || 'or') + " ");
        } else if (picks.length) {
          ellipsis = picks.length < totalCount ? '…' : '';
          return picks.join(', ') + ellipsis;
        }
      };

      return DropdownItemView;

    })(View);
    DropdownView = (function(superClass) {
      extend(DropdownView, superClass);

      function DropdownView() {
        return DropdownView.__super__.constructor.apply(this, arguments);
      }

      DropdownView.prototype.loadingSelector = '.filters-dropdown-loading';

      DropdownView.prototype.fallbackSelector = '.filters-dropdown-empty';

      DropdownView.prototype.errorSelector = '.filters-dropdown-service-error';

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

      FilterInputView.prototype.loadingSelector = '.filters-loading';

      FilterInputView.prototype.fallbackSelector = null;

      FilterInputView.prototype.errorSelector = '.filters-service-error';

      FilterInputView.prototype.itemView = FilterInputItemView;

      FilterInputView.prototype.listen = {
        'add collection': function() {
          return this.updateViewState();
        },
        'remove collection': function() {
          return this.updateViewState();
        },
        'reset collection': function() {
          return this.updateViewState();
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
        this.listenTo(this.groupSource, 'synced', function() {
          return this.updateViewState();
        });
        this.listenTo(this.groupSource, 'unsynced', function() {
          return this.updateViewState();
        });
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
        return this.updateViewState();
      };

      FilterInputView.prototype.updateViewState = function() {
        this.filterDropdownItems({
          force: true
        });
        return this.$('.remove-all-button').toggle(this.unrequiredSelection().length > 0);
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
        return this.collection.remove(this.unrequiredSelection());
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
          this.filterDropdownItems();
          if (this.query() !== '' && (item = _.first(this.visibleListItems()))) {
            return item.click();
          } else {
            return this.openDropdowns();
          }
        } else if (!this.selectedGroup && e.which === utils.keys.ESC) {
          e.preventDefault();
          return this.closeDropdowns();
        } else if (!this.selectedGroup && this.query() === '' && e.which === utils.keys.DELETE) {
          e.preventDefault();
          return this.collection.remove(_.last(this.unrequiredSelection()));
        } else if (this.selectedGroup && (e.which === utils.keys.ESC || (this.query() === '' && e.which === utils.keys.DELETE))) {
          e.preventDefault();
          this.resetInput();
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
        var $t, group, item, query;
        if (($t = $(e.currentTarget)).hasClass('disabled') || $t.hasClass('no-hover')) {
          return e.stopImmediatePropagation();
        }
        e.preventDefault();
        group = _.first(this.subview('dropdown-groups').modelsFrom(e.currentTarget));
        if (!group) {
          throw new Error('There is no group for clicked item!');
        }
        if (query = this.query()) {
          if (isLeaf(group)) {
            this.addSelectedItem(group, new Chaplin.Model({
              id: query,
              name: query
            }));
          } else if (item = matchingChild(group, regExp(query))) {
            this.addSelectedItem(group, item);
          } else {
            this.setSelectedGroup(group);
          }
        } else {
          this.setSelectedGroup(group);
        }
        return this["continue"] = true;
      };

      FilterInputView.prototype.onDropdownItemClick = function(e) {
        var $t, item;
        if (($t = $(e.currentTarget)).hasClass('disabled') || $t.hasClass('no-hover')) {
          return e.stopImmediatePropagation();
        }
        e.preventDefault();
        item = _.first(this.subview('dropdown-items').modelsFrom(e.currentTarget));
        this.addSelectedItem(this.selectedGroup, item);
        return this["continue"] = true;
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
          this.onGroupsDropdownHidden();
        } else if (this.activeDropdown() === 'items') {
          this.onItemsDropdownHidden();
        }
        return this.maybeContinue();
      };

      FilterInputView.prototype.onGroupsDropdownHidden = function() {
        if (this.selectedGroup) {
          this.activateDropdown('items');
          return this.openDropdowns();
        }
      };

      FilterInputView.prototype.onItemsDropdownHidden = function() {
        this.setSelectedGroup(void 0);
        return this.activateDropdown('groups');
      };

      FilterInputView.prototype.query = function() {
        return this.$('input').val() || '';
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
            return !_this.collection.find({
              id: groupItem.id,
              groupId: group.id
            });
          };
        })(this));
      };

      FilterInputView.prototype.unrequiredSelection = function() {
        return this.collection.filter(function(m) {
          return !m.get('required');
        });
      };

      FilterInputView.prototype.addSelectedItem = function(group, item) {
        var required, selectedItem;
        if (!(item && group)) {
          return;
        }
        selectedItem = item.clone();
        selectedItem.set({
          groupId: group.id,
          groupName: group.get('name')
        });
        if (required = group.get('required')) {
          selectedItem.set({
            required: required
          });
        }
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
        this.$('input').focus();
        return delete this["continue"];
      };

      FilterInputView.prototype.resetInput = function() {
        this.$('input').val('');
        return this.filterDropdownItems();
      };

      FilterInputView.prototype.filterDropdownItems = function(opts) {
        var applyFilter, dropdown, force, i, itemView, len, query, ref, visible;
        if (opts == null) {
          opts = {};
        }
        force = _.defaults(opts, {
          force: false
        }).force;
        applyFilter = (this.previousQuery || '') !== (query = this.query()) || force;
        if (!(!this.disposed && applyFilter)) {
          return;
        }
        dropdown = this.subview("dropdown-" + (this.activeDropdown()));
        dropdown.filter(this.dropdownFilterFunc());
        dropdown.toggleFallback();
        ref = _.values(dropdown.getItemViews());
        for (i = 0, len = ref.length; i < len; i++) {
          itemView = ref[i];
          visible = -1 < dropdown.visibleItems.indexOf(itemView.model);
          itemView.highlight(visible ? query : '');
        }
        return this.previousQuery = query;
      };

      FilterInputView.prototype.dropdownFilterFunc = function() {
        var inGroups, query, regexp;
        if (!(query = this.query())) {
          return null;
        }
        inGroups = this.activeDropdown() === 'groups';
        regexp = regExp(query);
        return function(item) {
          var include;
          include = (inGroups && isLeaf(item)) || matching(item, regexp) || (matchingChild(item, regexp) != null);
          return include || false;
        };
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
