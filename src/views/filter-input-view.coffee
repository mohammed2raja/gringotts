define (require) ->
  Chaplin = require 'chaplin'
  utils = require 'lib/utils'
  View = require 'views/base/view'
  CollectionView = require 'views/base/collection-view'

  class DropdownItemView extends View
    template: 'filter-input/list-item'
    noWrap: true

  class DropdownView extends CollectionView
    itemView: DropdownItemView
    getTemplateFunction: ->

  class FilterInputItemView extends View
    template: 'filter-input/item'
    noWrap: true

  class FilterInputView extends CollectionView
    optionNames: @::optionNames.concat ['groupSource']
    template: 'filter-input/view'
    className: 'filter-input form-control'
    loadingSelector: ".list-item#{@::loadingSelector}"
    fallbackSelector: null # no selected items is a default state
    errorSelector: ".list-item#{@::errorSelector}"
    itemView: FilterInputItemView
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
      'keydown .dropdown-items': (e) -> @onDropdownItemKeypress e
      'show.bs.dropdown .dropdown': (e) -> @onDropdownShow e
      'hide.bs.dropdown .dropdown': (e) -> @onDropdownHide e
      'hidden.bs.dropdown .dropdown': (e) -> @onDropdownHidden e

    initialize: (options={}) ->
      super
      @$el.addClass @className
      @placeholder = @$el.data('placeholder') or options.placeholder
      @disabled = @$el.data('disabled')? or options.disabled
      @groupSource ?= new Chaplin.Collection()
      @itemSource ?= new Chaplin.Collection()
      @filterDebounced = _.debounce @filterDropdownItems, 300

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

    onWhitespaceClick: (e) ->
      $target = $ e.target
      if $target.hasClass('form-control') or
          $target.hasClass('dropdown-control')
        e.stopPropagation()
        @openDropdowns()

    onItemRemoveClick: (e) ->
      @collection.remove @modelsFrom $(e.currentTarget).parent '.selected-item'

    onRemoveAllClick: (e) ->
      @collection.reset()

    onInputClick: (e) ->
      # keep opened dropdown visibile on second click
      e.stopPropagation() if @$('.dropdown').hasClass 'open'

    onInputKeydown: (e) ->
      if e.which is utils.keys.UP
        e.preventDefault()
        @visibleListItems().last().focus()
      else if e.which is utils.keys.DOWN
        e.preventDefault()
        @visibleListItems().first().focus()
      else if e.which is utils.keys.ENTER
        e.preventDefault()
        if (items = @visibleListItems()).length is 1
          @continue = true
          items[0].click()
        else
          @openDropdowns()
      else if @selectedGroup and
          (e.which is utils.keys.ESC or
            (@$('input').val() is '' and e.which is utils.keys.DELETE))
        e.preventDefault()
        @setSelectedGroup undefined
        @activateDropdown 'groups'

    onInputKeyup: (e) ->
      @filterDebounced()

    onInputFocus: (e) ->
      @$el.addClass 'focus'

    onInputBlur: (e) ->
      @$el.removeClass 'focus' unless @$('.dropdown').hasClass 'open'

    onDropdownGroupItemClick: (e) ->
      e.preventDefault()
      group = _.first @subview('dropdown-groups').modelsFrom e.currentTarget
      @setSelectedGroup group

    onDropdownItemClick: (e) ->
      e.preventDefault()
      item = _.first @subview('dropdown-items').modelsFrom e.currentTarget
      @addSelectedItem item

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
        @$('input').focus()

    onItemsDropdownHidden: ->
      @setSelectedGroup undefined
      @activateDropdown 'groups'
      if @continue
        @openDropdowns()
        @$('input').focus()
        delete @continue

    openDropdowns: ->
      @$('.dropdown').addClass 'open'
      @$el.addClass 'focus'

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
      _.filter group.get('children').models, (listItem) =>
        not _.any @collection.models, (item) -> item.id is listItem.id

    addSelectedItem: (item) ->
      return unless item and @selectedGroup
      selectedItem = item.clone()
      selectedItem.set
        groupId: @selectedGroup.get 'id'
        groupName: @selectedGroup.get 'name'
      @collection.add selectedItem

    resetInput: ->
      @$('input').val ''
      @filterDropdownItems()

    filterDropdownItems: ->
      return if @disposed
      if query = @$('input').val()
        regexp = new RegExp query, 'gi'
        filter = (item) -> regexp.test item.get 'name'
      else
        filter = null
      if @previousQuery isnt query
        dropdown = @subview "dropdown-#{@activeDropdown()}"
        dropdown.filter filter
        dropdown.toggleFallback()
        @previousQuery = query

    dispose: ->
      delete @groupSource
      delete @itemSource
      delete @selectedGroup
      super
