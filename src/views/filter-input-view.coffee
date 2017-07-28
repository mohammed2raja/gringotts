define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  View = require 'views/base/view'
  CollectionView = require 'views/base/collection-view'

  isLeaf = (model) ->
    not model.get('children')?

  class DropdownItemView extends View
    template: 'filter-input/list-item'
    noWrap: true
    render: ->
      super
      @$el.addClass('leaf') if isLeaf @model

  class DropdownView extends CollectionView
    loadingSelector: '.filters-dropdown-loading'
    fallbackSelector: '.filters-dropdown-empty'
    errorSelector: '.filters-dropdown-service-error'
    itemView: DropdownItemView
    getTemplateFunction: ->

  class FilterInputItemView extends View
    template: 'filter-input/item'
    noWrap: true

  class FilterInputView extends CollectionView
    optionNames: @::optionNames.concat ['groupSource']
    template: 'filter-input/view'
    className: 'form-control filter-input'
    listSelector: '.filter-items-container'
    loadingSelector: '.filters-loading'
    fallbackSelector: null # no selected items is a default state
    errorSelector: '.filters-service-error'
    itemView: FilterInputItemView
    listen:
      'add collection': -> @updateViewState()
      'remove collection': -> @updateViewState()
      'reset collection': -> @updateViewState()
    events:
      'click': (e) -> @onWhitespaceClick e
      'click .remove-button': (e) -> @onItemRemoveClick e
      'click .remove-all-button': (e) -> @onRemoveAllClick e
      'click input': (e) -> @onInputClick e
      'keydown input': (e) -> @onInputKeydown e
      'keyup input': (e) -> @onInputKeyup e
      'focus input': (e) -> @onInputFocus e
      'blur input': (e) -> @onInputBlur e
      'click .dropdown-groups li': (e) -> @onDropdownGroupItemClick e
      'click .dropdown-items li': (e) -> @onDropdownItemClick e
      'keydown .dropdown-groups': (e) -> @onDropdownGroupItemKeypress e
      'keydown .dropdown-items': (e) -> @onDropdownItemKeypress e
      'show.bs.dropdown .dropdown': (e) -> @onDropdownShow e
      'hide.bs.dropdown .dropdown': (e) -> @onDropdownHide e
      'hidden.bs.dropdown .dropdown': (e) -> @onDropdownHidden e

    initialize: (options={}) ->
      super
      @$el.removeClass(cl = @$el.attr 'class').addClass "#{@className} #{cl}"
      @placeholder = @$el.data('placeholder') or options.placeholder
      @disabled = @$el.data('disabled')? or options.disabled
      @groupSource ?= new Chaplin.Collection()
      @listenTo @groupSource, 'synced', -> @updateViewState()
      @listenTo @groupSource, 'unsynced', -> @updateViewState()
      @itemSource ?= new Chaplin.Collection()
      @filterDebounced = _.debounce @filterDropdownItems, 100

    getTemplateData: ->
      {
        @placeholder
        @disabled
        loadingText: I18n?.t('loading.text') or 'Loading...'
        emptyText: I18n?.t('filter_input.empty') or
          'There are no filters available'
        errorText: I18n?.t('filter_input.error') or
          'There was a problem while loading filters'
      }

    render: ->
      super
      @subview 'dropdown-groups', new DropdownView {
        el: @$ '.dropdown-groups'
        collection: @groupSource
      }
      @subview 'dropdown-items', new DropdownView {
        el: @$ '.dropdown-items'
        collection: @itemSource
      }
      @updateViewState()

    updateViewState: ->
      @filterDropdownItems force: yes
      @$('.remove-all-button').toggle @unrequiredSelection().length > 0

    onWhitespaceClick: (e) ->
      $target = $ e.target
      if $target.hasClass('filter-items-container') or
          $target.hasClass('dropdown-control')
        e.stopPropagation()
        @openDropdowns()

    onItemRemoveClick: (e) ->
      @collection.remove @modelsFrom $(e.currentTarget).parent '.selected-item'

    onRemoveAllClick: (e) ->
      @collection.remove @unrequiredSelection()

    onInputClick: (e) ->
      # keep opened dropdown visibile on second click
      e.stopPropagation() if @$('.dropdown').hasClass 'open'

    # coffeelint: disable=cyclomatic_complexity
    onInputKeydown: (e) ->
      if e.which is utils.keys.UP
        e.preventDefault()
        @visibleListItems().last().focus()
      else if e.which is utils.keys.DOWN
        e.preventDefault()
        @visibleListItems().first().focus()
      else if e.which is utils.keys.ENTER
        e.preventDefault()
        if @query() isnt '' and item = _.first @visibleListItems()
          @continue = true
          item.click()
        else
          @openDropdowns()
      else if not @selectedGroup and e.which is utils.keys.ESC
        e.preventDefault()
        @closeDropdowns()
      else if not @selectedGroup and @query() is '' and
          e.which is utils.keys.DELETE
        e.preventDefault()
        @collection.remove _.last @unrequiredSelection()
      else if @selectedGroup and
          (e.which is utils.keys.ESC or
            (@query() is '' and e.which is utils.keys.DELETE))
        e.preventDefault()
        @setSelectedGroup undefined
        @activateDropdown 'groups'
      else if /[\w\s]/.test String.fromCharCode e.which
        @openDropdowns()
    # coffeelint: enable=cyclomatic_complexity

    onInputKeyup: (e) ->
      @filterDebounced()

    onInputFocus: (e) ->
      @$el.addClass 'focus'

    onInputBlur: (e) ->
      unless @$('.dropdown').hasClass 'open'
        @$el.removeClass 'focus'
        @resetInput()

    onDropdownGroupItemClick: (e) ->
      if ($t = $ e.currentTarget).hasClass('disabled') or $t.hasClass 'no-hover'
        return e.stopImmediatePropagation()
      e.preventDefault()
      group = _.first @subview('dropdown-groups').modelsFrom e.currentTarget
      unless isLeaf group
        @setSelectedGroup group
      else if query = @query()
        @addSelectedItem group, new Chaplin.Model id: query, name: query

    onDropdownItemClick: (e) ->
      if ($t = $ e.currentTarget).hasClass('disabled') or $t.hasClass 'no-hover'
        return e.stopImmediatePropagation()
      e.preventDefault()
      item = _.first @subview('dropdown-items').modelsFrom e.currentTarget
      @addSelectedItem @selectedGroup, item

    onDropdownGroupItemKeypress: (e) ->
      @continue = true if e.which in [utils.keys.ENTER]

    onDropdownItemKeypress: (e) ->
      @continue = true if e.which in [utils.keys.ENTER, utils.keys.ESC]

    onDropdownShow: (e) ->
      @$el.addClass 'focus'

    onDropdownHide: (e) ->
      @$el.removeClass 'focus'

    onDropdownHidden: (e) ->
      @resetInput()
      if @activeDropdown() is 'groups'
        @onGroupsDropdownHidden()
      else if @activeDropdown() is 'items'
        @onItemsDropdownHidden()

    onGroupsDropdownHidden: ->
      if @selectedGroup
        @activateDropdown 'items'
        @openDropdowns()
      else
        @maybeContinue()

    onItemsDropdownHidden: ->
      @setSelectedGroup undefined
      @activateDropdown 'groups'
      @maybeContinue()

    query: ->
      @$('input').val() or ''

    openDropdowns: ->
      @$('.dropdown').addClass 'open'
      @$('input').focus()

    closeDropdowns: ->
      @$('.dropdown').removeClass 'open'

    visibleListItems: ->
      @$('.dropdown-menu:not(.hidden) a:visible')

    activeDropdown: ->
      return 'items' if @$('.dropdown-groups').hasClass 'hidden'
      return 'groups' if @$('.dropdown-items').hasClass 'hidden'

    activateDropdown: (target) ->
      another = if target is 'groups' then 'items' else 'groups'
      @$(".dropdown-#{target}").toggleClass 'hidden', no
      @$(".dropdown-#{another}").toggleClass 'hidden', yes

    setSelectedGroup: (group) ->
      @selectedGroup = group
      @$('.selected-group').text group?.get('name') or ''
      @itemSource.reset @groupItems group
      @subview('dropdown-items').toggleFallback()

    groupItems: (group) ->
      return [] unless group
      group.get('children').filter (groupItem) =>
        not @collection.find id: groupItem.id, groupId: group.id

    unrequiredSelection: ->
      @collection.filter (m) -> not m.get 'required'

    addSelectedItem: (group, item) ->
      return unless item and group
      selectedItem = item.clone()
      selectedItem.set
        groupId: group.id
        groupName: group.get 'name'
      if required = group.get 'required'
        selectedItem.set {required}
      if group.get 'singular'
        @collection.remove @collection.filter groupId: group.id
      @collection.add selectedItem

    maybeContinue: ->
      return unless @continue
      @openDropdowns()
      delete @continue

    resetInput: ->
      @$('input').val ''
      @filterDropdownItems()

    filterDropdownItems: (opts={}) ->
      return if @disposed
      {force} = _.defaults opts, force: no
      inGroups = @activeDropdown() is 'groups'
      if query = @query()
        regexp = try new RegExp query, 'i'
        filter = (item) -> # always show all group leafs
          (inGroups and isLeaf item) or regexp?.test item.get 'name'
      else
        filter = null
      if (@previousQuery or '') isnt query or force
        dropdown = @subview "dropdown-#{@activeDropdown()}"
        dropdown.filter filter
        names = 'li' + (if inGroups then ':not(.leaf)' else '') + ' .item-name'
        dropdown.find(names).each (i, el) ->
          ($el = $ el).html $el.text().replace regexp, '<i>$&</i>'
        if inGroups
          dropdown.find('li.leaf').each (i, el) ->
            ($el = $ el).find('.item-note').text query
            ($el = $ el).toggleClass 'disabled no-hover', query is ''
        dropdown.toggleFallback()
        @previousQuery = query

    dispose: ->
      delete @groupSource
      delete @itemSource
      delete @selectedGroup
      super
