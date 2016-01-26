define (require) ->
  Handlebars = require 'handlebars'
  utils = require '../../lib/utils'
  CollectionView = require './collection-view'

  class PaginatedView extends CollectionView
    paginationPartial: 'pagination'

    ###*
     * Overriding chaplin's toggleLoadingIndicator to
     * remove the collection length requirement.
    ###
    toggleLoadingIndicator: ->
      itemClassName = utils.convenienceClass @itemView::className,
        @itemView::template

      # Added requirement here to make the loading indicator
      # functionality more flexible.
      unless itemClassName
        throw new Error "Please define a className for your itemViews."

      visible = @collection.isSyncing()
      @$(".#{itemClassName.split(/\s+|\s+/).join('.')}").toggle !visible
      @$loading.toggle visible

    _getPageInfo: ->
      state = @collection.getState {}, true

      _.each ['page', 'per_page'], (i) ->
        state[i] = parseInt state[i]

      info = # setup what the pagination template is expecting
        viewId: @cid
        count: @collection.count
        page: state.page
        perPage: state.per_page
        pages: Math.ceil @collection.count / state.per_page
        prev: false
        next: false

      maxItems = info.pages * info.perPage
      max = Math.min @collection.count, info.page * info.perPage
      max = @collection.count if @collection.count is maxItems
      min = (info.page - 1) * info.perPage + 1
      min = Math.min min, max
      info.range = [min, max].join '-'
      info.prev = state.page - 1 if state.page > 1
      info.next = state.page + 1 if state.page < info.pages
      info.routeName = @routeName
      info.routeParams = @routeParams
      info.multiPaged = info.count > info.perPage

      info.nextState = if info.next
        @collection.getState page: info.next
      else @collection.getState()

      info.prevState = if info.prev
        @collection.getState page: info.prev
      else @collection.getState()

      info

    ###*
     * Add the pageInfo context into the view template.
     * Render using {{> pagination pageInfo}}.
     * @return {object} Context for use within the template.
    ###
    getTemplateData: ->
      _.extend super, pageInfo: @_getPageInfo()

    renderControls: ->
      super
      pageInfo = @_getPageInfo()
      template = Handlebars.partials[@paginationPartial]
      return unless pageInfo and template
      @$(".pagination-controls.#{@cid}").each (i, el) ->
        $(el).replaceWith template pageInfo
