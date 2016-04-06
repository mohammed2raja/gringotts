define (require) ->
  ###*
   * Adds on an automation id for QE purposes.
   * Based on the template property.
  ###
  (superclass) -> class Automatable extends superclass
    render: ->
      if @template and id = @template.replace /\//g, '-'
        @$el.attr 'qe-id', id
      super
