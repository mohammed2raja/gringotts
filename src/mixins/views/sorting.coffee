define (require) ->
  handlebars = require 'handlebars'
  utils = require 'lib/utils'
  helper = require '../helper'
  Routing = require './routing'

  ###*
   * Adds sorting support to a CollectionView. It relies on Routing
   * mixin to get current route name and params to generate sorting links.
   * @param  {CollectionView} base superclass
  ###
  (base) -> class Sorting extends utils.mix(base).with Routing
    ###*
     * Name of handlebars partial with sorting controls.
     * @type {String}
    ###
    sortingPartial: 'sortTableHeader'

    ###*
     * A hash of model attribute names and their string labels that are
     * expected to be sortable in the table.
     * @type {Object}
    ###
    sortableTableHeaders: null

    listen:
      # Re-render all sorting partials
      'request collection': -> @renderSortingControls()
      'sync collection': -> @renderSortingControls()
      'sort collection': -> @renderSortingControls()

    initialize: ->
      helper.assertCollectionView this
      unless @sortableTableHeaders
        throw new Error 'The sortableTableHeaders should be set for this view.'
      unless _.isFunction @collection?.getState
        throw new Error 'This view should have collection with
          getState() method. Most probably with Sorted mixin applied.'
      super

    getTemplateData: ->
      _.extend super, sortInfo: @getSortInfo()

    render: ->
      unless @routeName
        throw new Error "Can't render view when routeName isn't set"
      super

    renderAllItems: ->
      super
      @highlightColumns()

    getSortInfo: ->
      state = @collection.getState {}, inclDefaults: yes, usePrefix: no
      if !state.sort_by
        throw new Error 'Please define a sort_by attribute within DEFAULTS'
      _.transform @sortableTableHeaders, (result, title, column) =>
        order = if column is state.sort_by then state.order else ''
        nextOrder = if order is 'asc' then 'desc' else 'asc'
        result[column] =
          viewId: @cid
          attr: column
          text: title
          order: order
          routeName: @routeName
          routeParams: @routeParams
          nextState: @collection.getState order: nextOrder, sort_by: column
        result
      , {}

    ###*
     * Highlights with a css class currently sorted table column.
    ###
    highlightColumns: ->
      state = @collection.getState {}, inclDefaults: yes, usePrefix: no
      idx = @$("th[data-sort=#{state.sort_by}]").index()
      @$("#{@listSelector} #{@itemView::tagName} td")
        .removeClass 'highlighted'
        .filter ":nth-child(#{idx + 1})"
        .not '[colspan]' # remove indicator rows which take up the entire width
        .addClass 'highlighted'

    renderSortingControls: ->
      sortInfo = @getSortInfo()
      template = handlebars.partials[@sortingPartial]
      return unless sortInfo and template
      @$(".sorting-control.#{@cid}").each (i, el) ->
        $el = $(el)
        attr = $el.attr 'data-sort'
        $el.replaceWith template {sortInfo, attr}
