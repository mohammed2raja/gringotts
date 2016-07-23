define (require) ->
  ###*
   * Add two properties routeName and routeParams to a View or CollectionView
   * that are used for passing context for Chaplin routing utils.
   * @param  {View|CollectionView} superclass Only views
  ###
  (superclass) -> class Routing extends superclass
    optionNames: @::optionNames.concat ['routeName', 'routeParams']

    initItemView: ->
      view = super
      view.routeName = @routeName
      view.routeParams = @routeParams
      view

    getTemplateData: ->
      _.extend super,
        routeName: @routeName
        routeParams: @routeParams
