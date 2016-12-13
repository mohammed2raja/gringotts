define (require) ->
  handlebars = require 'handlebars'
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'
  Routing = require './routing'

  ###*
   * Adds sorting support to a CollectionView. It relies on Routing
   * mixin to get current route name and params to generate sorting links.
   * @param  {CollectionView} base superclass
  ###
  (base) -> class Sorting extends utils.mix(base).with Routing
    helper.setTypeName @prototype, 'Sorting'

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

    initialize: ->
      helper.assertCollectionView this
      unless @sortableTableHeaders
        throw new Error 'The sortableTableHeaders should be set for this view.'
      super
      unless @routeQueryable
        throw new Error 'This view should have a collection with
          applied Queryable mixin.'
      @listenTo @routeQueryable, 'queryChange', (info) ->
        @renderSortingControls()

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
      query = @getBrowserQuery()
      if !query.sort_by
        throw new Error 'Please define a sort_by attribute within DEFAULTS'
      _.transform @sortableTableHeaders, (result, title, column) =>
        order = if column is query.sort_by then query.order else ''
        nextOrder = if order is 'asc' then 'desc' else 'asc'
        result[column] =
          viewId: @cid
          attr: column
          text: title
          order: order
          routeName: @routeName
          routeParams: @routeParams
          nextQuery: @routeQueryable.getQuery overrides:
            order: nextOrder, sort_by: column
        result
      , {}

    ###*
     * Highlights with a css class currently sorted table column.
    ###
    highlightColumns: ->
      query = @getBrowserQuery()
      idx = @$("th[data-sort=#{query.sort_by}]").index()
      @$("#{@listSelector} #{@itemView::tagName} td")
        .removeClass 'highlighted'
        .filter ":nth-child(#{idx + 1})"
        .not '[colspan]' # remove indicator rows which take up the entire width
        .addClass 'highlighted'

    renderSortingControls: ->
      sortInfo = @getSortInfo()
      template = handlebars.partials[@sortingPartial]
      return unless sortInfo and template
      @$(".sorting-control.#{@cid}").each (i, el) =>
        $el = $(el)
        attr = $el.attr 'data-sort'
        classes = $el.removeClass("sorting-control #{@cid}").attr 'class'
        $el.replaceWith template {sortInfo, attr, class: classes}
