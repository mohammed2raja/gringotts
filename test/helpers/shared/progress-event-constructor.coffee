# Needed for Sinon AJAX/server stuff to work in CLI.
# https://github.com/cjohansen/Sinon.JS/issues/319#issuecomment-34325683
define ->
  if window.PHANTOMJS
    window.ProgressEvent = (type, params) ->
      params = params or {}
      @lengthComputable = params.lengthComputable or false
      @loaded = params.loaded or 0
      @total = params.total or 0
