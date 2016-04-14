define (require) ->
  ###*
   * Just another way to add custom css class to View element
   * without interfering with Backbone View's className.
   * @param  {Backbone.View} superclass
  ###
  (superclass) -> class Classy extends superclass
    classyName: null

    initialize: ->
      super
      unless _.isFunction @render
        throw new Error 'Classy mixin works only with Backbone.View'

    render: ->
      if @classyName
        className = @$el.attr('class') or ''
        className += ' ' unless className is ''
        unless new RegExp("(^|\\s+)#{@classyName}(\\s+|$)", 'ig').test className
          @$el.attr 'class', "#{className}#{@classyName}"
      super
