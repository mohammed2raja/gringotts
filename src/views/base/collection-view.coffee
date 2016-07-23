define (require) ->
  Chaplin = require 'chaplin'
  handlebars = require 'handlebars'
  utils = require '../../lib/utils'
  Routing = require '../../mixins/routing'
  StringTemplatable = require '../../mixins/string-templatable'
  ServiceErrorReady = require '../../mixins/service-error-ready'

  ###*
   * @param {object} sortableTableHeaders - Headers for the table.
  ###
  class CollectionView extends utils.mix Chaplin.CollectionView
      .with StringTemplatable, ServiceErrorReady, Routing

    listen:
      # Re-render all partials with *-Infos
      'request collection': -> @renderControls()
      'sync collection': -> @renderControls()
      'sort collection': -> @renderControls()
    optionNames: @::optionNames.concat ['sortableTableHeaders']
    loadingSelector: '.loading'
    fallbackSelector: '.empty'
    sortingPartial: 'sortTableHeader'
    useCssAnimation: yes
    animationStartClass: 'fade'
    animationEndClass: 'in'

    highlightColumns: ->
      state = @collection.getState {}, inclDefaults: yes
      idx = @$("th[data-sort=#{state.sort_by}]").index()
      @$("#{@listSelector} #{@itemView::tagName} td")
        .removeClass 'highlighted'
        .filter ":nth-child(#{idx + 1})"
        .not '[colspan]' # remove indicator rows which take up the entire width
        .addClass 'highlighted'

    getSortInfo: ->
      return null unless @sortableTableHeaders
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

    getTemplateData: ->
      sortInfo = @getSortInfo()
      if sortInfo then _.extend super, {sortInfo}
      else super

    renderAllItems: ->
      super
      @highlightColumns() if @sortableTableHeaders

    renderControls: ->
      sortInfo = @getSortInfo()
      template = handlebars.partials[@sortingPartial]
      return unless sortInfo and template
      @$(".sorting-control.#{@cid}").each (i, el) ->
        $el = $(el)
        attr = $el.attr 'data-sort'
        $el.replaceWith template {sortInfo, attr}
