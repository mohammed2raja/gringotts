define (require) ->
  handlebars = require 'handlebars'
  utils = require 'lib/utils'
  helper = require '../helper'
  Routing = require './routing'

  ###*
   * Adds pagination support to a CollectionView. It relies on Routing
   * mixin to get current route name and params to generate pagination links.
   * @param  {CollectionView} base superclass
  ###
  (base) -> class Paginating extends utils.mix(base).with Routing
    ###*
     * Name of handlebars partial with pagination controls.
     * @type {String}
    ###
    paginationPartial: 'pagination'

    listen:
      # Re-render all paginating partials
      'request collection': -> @renderPaginatingControls()
      'sync collection': -> @renderPaginatingControls()
      'sort collection': -> @renderPaginatingControls()

    initialize: ->
      helper.assertCollectionView this
      unless _.isFunction @collection?.getState
        throw new Error 'This view should have a collection with
          getState() method. Most probably with Paginated mixin applied.'
      unless _.isFunction @collection?.isSyncing
        throw new Error 'This view should have a collection with
          isSyncing() method. Most probably with ActiveSyncMachine
          mixin applied.'
      super

    ###*
     * Add the pageInfo context into the view template.
     * Render using {{> pagination pageInfo}}.
     * @return {object} Context for use within the template.
    ###
    getTemplateData: ->
      _.extend super, pageInfo: @getPageInfo()

    render: ->
      unless @routeName
        throw new Error "Can't render view when routeName isn't set"
      super

    ###*
     * Overriding chaplin's toggleLoadingIndicator to
     * remove the collection length requirement.
    ###
    toggleLoadingIndicator: ->
      visible = @collection.isSyncing()
      @$('tbody > tr').not(@loadingSelector).not(@fallbackSelector)
        .not(@errorSelector).toggle !visible
      @$loading.toggle visible

    getStats: (min, max, info) ->
      if I18n?
        I18n.t 'items.total', start: min, end: max, total: info.count
      else
        "#{[min, max].join '-'} of #{info.count}"

    getRangeString: (page, perPage, info) ->
      maxItems = info.pages * perPage
      max =
        if info.count is maxItems then info.count
        else Math.min info.count, page * perPage
      min = (page - 1) * perPage + 1
      min = Math.min min, max
      @getStats min, max, info

    # setup what the pagination template is expecting
    getPageInfo: ->
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
        info.range = @getRangeString page, perPage, info

      info.nextState =
        if info.next then @collection.getState page: info.next
        else @collection.getState()
      info.prevState =
        if info.prev then @collection.getState page: info.prev
        else @collection.getState()

      info.routeName = @routeName
      info.routeParams = @routeParams
      info

    renderPaginatingControls: ->
      pageInfo = @getPageInfo()
      template = handlebars.partials[@paginationPartial]
      return unless pageInfo and template
      @$(".pagination-controls.#{@cid}").each (i, el) ->
        $(el).replaceWith template pageInfo
