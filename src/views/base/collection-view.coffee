define (require) ->
  Chaplin = require 'chaplin'
  Handlebars = require 'handlebars'
  advice = require '../../mixins/advice'
  stringTemplate = require '../../mixins/string-template'
  convenienceClass = require '../../mixins/convenience-class'
  errorToggleView = require '../../mixins/error-toggle-view'

  ###*
   * @param {object} sortableTableHeaders - Headers for the table.
   * @param {string} template
  ###
  class CollectionView extends Chaplin.CollectionView
    advice.call @prototype
    stringTemplate.call @prototype
    convenienceClass.call @prototype
    errorToggleView.call @prototype

    listen:
      # Re-render all partials with *-Infos
      'request collection': -> @renderControls()
      'sync collection': -> @renderControls()
      'sort collection': -> @renderControls()

    optionNames: Chaplin.CollectionView::optionNames.concat [
      'template', 'sortableTableHeaders', 'routeName', 'routeParams'
    ]

    loadingSelector: '.loading'
    fallbackSelector: '.empty'
    sortingPartial: 'sortTableHeader'

    _highlightColumns: ->
      state = @collection.getState {}, true
      idx = @$("th[data-sort=#{state.sort_by}]").index()
      @$("#{@listSelector} #{@itemView::tagName} td")
        .removeClass 'highlighted'
        .filter ":nth-child(#{idx + 1})"
        .not '[colspan]' # remove indicator rows which take up the entire width
        .addClass 'highlighted'

    _getSortInfo: ->
      return null unless @sortableTableHeaders
      state = @collection.getState {}, true

      if !state.sort_by
        throw new Error 'Please define a sort_by attribute within DEFAULTS'

      _.transform @sortableTableHeaders, (result, v, k) ->
        order = if k is state.sort_by then state.order else ''
        nextOrder = if order is 'desc' then 'asc'
        else if order is 'asc' then 'desc'
        else @collection.DEFAULTS.order
        result[k] =
          viewId: @cid
          attr: k
          text: v
          order: order
          routeName: @routeName
          routeParams: @routeParams
          nextState: @collection.getState {order: nextOrder, sort_by: k}
        result
      , {}, this

    getTemplateData: ->
      sortInfo = @_getSortInfo()
      if sortInfo then _.extend super, {sortInfo}
      else super

    renderAllItems: ->
      super
      @_highlightColumns() if @sortableTableHeaders

    renderControls: ->
      sortInfo = @_getSortInfo()
      template = Handlebars.partials[@sortingPartial]
      return unless sortInfo and template
      @$(".sorting-control.#{@cid}").each (i, el) ->
        $el = $(el)
        attr = $el.attr 'data-sort'
        $el.replaceWith template {sortInfo, attr}
