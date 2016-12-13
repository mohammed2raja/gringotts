define (require) ->
  handlebars = require 'handlebars'
  utils = require 'lib/utils'
  helper = require '../../lib/mixin-helper'
  Routing = require './routing'

  ###*
   * Adds pagination support to a CollectionView. It relies on Routing
   * mixin to get current route name and params to generate pagination links.
   * @param  {CollectionView} base superclass
  ###
  (base) -> class Paginating extends utils.mix(base).with Routing
    helper.setTypeName @prototype, 'Paginating'

    ###*
     * Name of handlebars partial with pagination controls.
     * @type {String}
    ###
    paginationPartial: 'pagination'

    listen:
      'sync collection': ->
        # collection count could be updated
        @renderPaginatingControls()

    initialize: ->
      helper.assertCollectionView this
      super
      unless @routeQueryable
        throw new Error 'This view should have a collection with
          applied Queryable mixin.'
      @listenTo @routeQueryable, 'queryChange', (info) ->
        @renderPaginatingControls()

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
      query = @getBrowserQuery()
      perPage = parseInt query.per_page
      page = if infinite then query.page else parseInt query.page
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

      info.nextQuery =
        if info.next then @routeQueryable.getQuery overrides: page: info.next
        else @routeQueryable.getQuery()
      info.prevQuery =
        if info.prev then @routeQueryable.getQuery overrides: page: info.prev
        else @routeQueryable.getQuery()

      info.routeName = @routeName
      info.routeParams = @routeParams
      info

    renderPaginatingControls: ->
      pageInfo = @getPageInfo()
      template = handlebars.partials[@paginationPartial]
      return unless pageInfo and template
      @$(".pagination-controls.#{@cid}").each (i, el) ->
        $(el).replaceWith template pageInfo
