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
      visible = @collection.isSyncing()
      @$('tbody > tr').not(@loadingSelector).not(@fallbackSelector)
        .not(@errorSelector).toggle !visible
      @$loading.toggle visible

    _getStats: (min, max, info) ->
      if I18n?
        I18n.t 'items.total', start: min, end: max, total: info.count
      else
        "#{[min, max].join '-'} of #{info.count}"

    _getRangeString: (page, perPage, info) ->
      maxItems = info.pages * perPage
      max =
        if info.count is maxItems then info.count
        else Math.min info.count, page * perPage
      min = (page - 1) * perPage + 1
      min = Math.min min, max
      @_getStats min, max, info

    # setup what the pagination template is expecting
    _getPageInfo: ->
      infinite = @collection.infinite
      state = @collection.getState {}, inclDefaults: yes, usePrefix: no
      perPage = parseInt state.per_page
      page = if infinite then state.page else parseInt state.page
      info =
        viewId: @cid
        count: @collection.count
        page: page
        perPage: perPage

      if infinite
        info.pages = 1
        info.multiPaged = true
        info.prev = if page isnt 1 then 1 else 0
        info.next = @collection.nextPageId
      else
        info.pages = Math.ceil @collection.count / perPage
        info.multiPaged = @collection.count > perPage
        info.prev = if page > 1 then page - 1 else 0
        info.next = if page < info.pages then page + 1 else 0
        info.range = @_getRangeString page, perPage, info

      info.nextState =
        if info.next then @collection.getState page: info.next
        else @collection.getState()
      info.prevState =
        if info.prev then @collection.getState page: info.prev
        else @collection.getState()

      info.routeName = @routeName
      info.routeParams = @routeParams
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
