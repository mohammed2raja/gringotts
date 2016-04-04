define (require) ->
  (superclass) -> class Content extends superclass
    container: '#content'
    containerMethod: 'prepend'
