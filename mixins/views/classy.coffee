import helper from '../../lib/mixin-helper'

###*
  * Just another way to add custom css class to View element
  * without interfering with Backbone View's className.
  * @param  {Backbone.View} superclass
###
export default (superclass) -> helper.apply superclass, (superclass) -> \

class Classy extends superclass
  helper.setTypeName @prototype, 'Classy'

  classyName: null

  initialize: ->
    helper.assertViewOrCollectionView this
    super arguments...

  render: ->
    if @classyName
      className = @$el.attr('class') or ''
      className += ' ' unless className is ''
      unless new RegExp("(^|\\s+)#{@classyName}(\\s+|$)", 'ig').test className
        @$el.attr 'class', "#{className}#{@classyName}"
    super()
