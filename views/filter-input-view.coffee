import Chaplin from 'chaplin'
import handlebars from 'handlebars/runtime'
import {keys} from '../lib/utils'
import View from './base/view'
import CollectionView from './base/collection-view'
import template from './filter-input/view'
import itemTemplate from './filter-input/item'
import listItemTemplate from './filter-input/list-item'

DESCRIPTION_MAX_LENGTH = 40

isLeaf = (model) ->
  not model.get('children')?

regExp = (query, opts = {}) ->
  return unless query
  {startsWith} = _.defaults opts, startsWith: yes
  # always match numbers anywhere inside filter names
  mode = if !!parseInt query then '()' \
    else (if startsWith then '^()' else '(^|\\W)')
  try new RegExp "#{mode}(#{query})", 'i'

matching = (item, regexp) ->
  regexp?.test item.get 'name'

matchingChild = (group, regexp) ->
  _.head group?.get('children')?.filter (c) -> matching c, regexp

highlightMatch = (text, regexp) ->
  new handlebars.SafeString text?.replace regexp, '$1<i>$2</i>'

class DropdownItemView extends View
  template: listItemTemplate
  tagName: 'li'
  query: ''
  className: ->
    (if @isLeaf then 'leaf ' else '') + 'filter-item'

  constructor: ({model}) ->
    super arguments...
    @isLeaf = isLeaf model
    @isAction = model.get 'action'
    @needsDescription = not @isLeaf and not model.get 'description'
    if @needsDescription
      @listenTo @model.get('children'), 'synced', -> @render()

  getTemplateData: ->
    data = super()
    if @needsDescription
      _.extend data, description: @generateDesc()
    if @query
      if @isAction
        data.note = @query
      else
        data.name = highlightMatch data.name, regExp @query
        if data.description
          data.description = highlightMatch data.description,
            regExp @query, startsWith: no
    data

  render: ->
    super()
    if @isAction
      @$el.toggleClass 'disabled no-hover', @query is ''

  highlight: (query) ->
    return unless @query isnt query
    @query = query
    @description = null
    @render()

  generateDesc: ->
    return @description if @description
    if (children = @model.get 'children').length
      picks = []
      totalLength = 0
      for name in _.compact children.pluck 'name'
        break unless (totalLength += name.length) <= DESCRIPTION_MAX_LENGTH
        picks.push name.trim()
      match = matchingChild(@model, regExp @query)?.get 'name' if @query
      picks = _.union(picks, [match] if match)
      @description = @unionDesc picks, children.length
    else
      I18n?.t('loading.text') or 'Loading...'

  unionDesc: (picks, totalCount) ->
    if picks.length is 2 and totalCount is 2
      picks.join " #{I18n?.t('labels.or') or 'or'} " # or what?..
    else if picks.length
      ellipsis = if picks.length < totalCount then '…' else ''
      picks.join(', ') + ellipsis

class DropdownView extends CollectionView
  loadingSelector: '.filters-dropdown-loading'
  fallbackSelector: '.filters-dropdown-empty'
  errorSelector: '.filters-dropdown-service-error'
  itemView: DropdownItemView
  getTemplateFunction: ->

class FilterInputItemView extends View
  template: itemTemplate
  noWrap: true

export default class FilterInputView extends CollectionView
  optionNames: @::optionNames.concat ['groupSource']
  template: template
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
    'show.bs.dropdown .dropdown': (e) -> @onDropdownShow e
    'hide.bs.dropdown .dropdown': (e) -> @onDropdownHide e
    'hidden.bs.dropdown .dropdown': (e) -> @onDropdownHidden e

  initialize: ({disabled, placeholder} = {}) ->
    super arguments...
    @$el.removeClass(cl = @$el.attr 'class').addClass "#{@className} #{cl}"
    @placeholder = @$el.data('placeholder') or placeholder
    @disabled @$el.data('disabled')? or disabled
    @groupSource ?= new Chaplin.Collection()
    @listenTo @groupSource, 'synced', -> @updateViewState()
    @listenTo @groupSource, 'unsynced', -> @updateViewState()
    @itemSource ?= new Chaplin.Collection()
    @filterDebounced = _.debounce @filterDropdownItems, 100

  getTemplateData: ->
    {
      @placeholder
      disabled: @disabled()
      loadingText: I18n?.t('loading.text') or 'Loading...'
      emptyText: I18n?.t('filter_input.empty') or
        'There are no filters available'
      errorText: I18n?.t('filter_input.error') or
        'There was a problem while loading filters'
    }

  render: ->
    super()
    @subview 'dropdown-groups', new DropdownView {
      el: @$ '.dropdown-groups'
      collection: @groupSource
    }
    @subview 'dropdown-items', new DropdownView {
      el: @$ '.dropdown-items'
      collection: @itemSource
    }
    @updateViewState()

  disabled: (value) ->
    if value is undefined
      @$el.hasClass 'disabled'
    else
      @$('input').prop 'disabled', value
      @$el.toggleClass 'disabled', value

  updateViewState: ->
    @filterDropdownItems force: yes
    @$('.remove-all-button').toggle @unrequiredSelection().length > 0

  onWhitespaceClick: (e) ->
    return if @disabled()
    $target = $ e.target
    if $target.hasClass('filter-items-container') or
        $target.hasClass('dropdown-control')
      e.stopPropagation()
      @openDropdowns()

  onItemRemoveClick: (e) ->
    return if @disabled()
    @collection.remove @modelsFrom $(e.currentTarget).parent '.selected-item'

  onRemoveAllClick: (e) ->
    return if @disabled()
    @collection.remove @unrequiredSelection()

  onInputClick: (e) ->
    return if @disabled()
    # keep opened dropdown visibile on second click
    e.stopPropagation() if @$('.dropdown').hasClass 'open'

  # coffeelint: disable=cyclomatic_complexity
  onInputKeydown: (e) ->
    return if @disabled()
    if e.which is keys.UP
      e.preventDefault()
      @visibleListItems().last().focus()
    else if e.which is keys.DOWN
      e.preventDefault()
      @visibleListItems().first().focus()
    else if e.which is keys.ENTER
      e.preventDefault()
      @filterDropdownItems() # for quick types then enter
      if @query() isnt '' and item = _.head @visibleListItems()
        item.click()
      else
        @openDropdowns()
    else if not @selectedGroup and e.which is keys.ESC
      e.preventDefault()
      @closeDropdowns()
    else if not @selectedGroup and @query() is '' and
        e.which is keys.DELETE
      e.preventDefault()
      @collection.remove _.last @unrequiredSelection()
    else if @selectedGroup and
        (e.which is keys.ESC or
          (@query() is '' and e.which is keys.DELETE))
      e.preventDefault()
      @resetInput()
      @setSelectedGroup undefined
      @activateDropdown 'groups'
    else if /[\w\s]/.test String.fromCharCode e.which
      @openDropdowns()
  # coffeelint: enable=cyclomatic_complexity

  onInputKeyup: (e) ->
    return if @disabled()
    @filterDebounced()

  onInputFocus: (e) ->
    return if @disabled()
    @$el.addClass 'focus'

  onInputBlur: (e) ->
    unless @$('.dropdown').hasClass 'open'
      @$el.removeClass 'focus'
      @resetInput()

  onDropdownGroupItemClick: (e) ->
    if ($t = $ e.currentTarget).hasClass('disabled') or $t.hasClass 'no-hover'
      return e.stopImmediatePropagation()
    e.preventDefault()
    group = _.head @subview('dropdown-groups').modelsFrom e.currentTarget
    throw new Error('There is no group for clicked item!') unless group
    if query = @query()
      if isLeaf group # like Search action
        @addSelectedItem group, new Chaplin.Model id: query, name: query
      else if item = matchingChild group, regExp query # match in filter items
        @addSelectedItem group, item
      else # select only matching group, show items in items dropdown
        @setSelectedGroup group
    else
      @setSelectedGroup group
    @continue = true

  onDropdownItemClick: (e) ->
    if ($t = $ e.currentTarget).hasClass('disabled') or $t.hasClass 'no-hover'
      return e.stopImmediatePropagation()
    e.preventDefault()
    item = _.head @subview('dropdown-items').modelsFrom e.currentTarget
    @addSelectedItem @selectedGroup, item
    @continue = true

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
    @maybeContinue()

  onGroupsDropdownHidden: ->
    if @selectedGroup
      @activateDropdown 'items'
      @openDropdowns()

  onItemsDropdownHidden: ->
    @setSelectedGroup undefined
    @activateDropdown 'groups'

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
      @collection.remove @collection.filter(groupId: group.id),
        singularReplacement: yes
    @collection.add selectedItem

  maybeContinue: ->
    return unless @continue
    @$('input').focus()
    delete @continue

  resetInput: ->
    @$('input').val ''
    @filterDropdownItems()

  filterDropdownItems: (opts = {}) ->
    {force} = _.defaults opts, force: no
    applyFilter = (@previousQuery or '') isnt (query = @query()) or force
    return unless not @disposed and applyFilter
    dropdown = @subview "dropdown-#{@activeDropdown()}"
    dropdown.filter @dropdownFilterFunc()
    dropdown.toggleFallback()
    for itemView in _.values dropdown.getItemViews()
      visible = -1 < dropdown.visibleItems.indexOf itemView.model
      itemView.highlight if visible then query else ''
    @previousQuery = query

  dropdownFilterFunc: ->
    return null unless query = @query()
    inGroups = @activeDropdown() is 'groups'
    regexp = regExp query
    (item) ->
      # always show leafs in groups
      include = (inGroups and isLeaf item) or
        matching(item, regexp) or matchingChild(item, regexp)?
      include or no # Boolean type is expected as result

  dispose: ->
    delete @groupSource
    delete @itemSource
    delete @selectedGroup
    super()
