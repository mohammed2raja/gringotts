define (require) ->
  initMochaBlanket: (success) ->
    if window.PHANTOMJS # index-phantomjs has direct include of mocha/blanket
      success()
    else
      if window.location.search.indexOf('cov=true') >= 0
        require ['mocha-blanket'], -> success()
      else
        require ['mocha'], -> success()

  setupUI: ->
    return if window.PHANTOMJS
    if window.blanket
      $fullCoverageRows = ->
        $("#blanket-main .rs:contains('100 %')").parent ':not(.grand-total)'
      report = window.blanket.report
      window.blanket.report = ->
        report.apply window.blanket, arguments
        $fullCoverageRows().hide()
        $('.bl-success:not(.grand-total) > .rs:nth-child(4)').each ->
          statements = @innerHTML.split '/'
          covered = parseInt statements[0]
          total = parseInt statements[1]
          $(@parentNode).show() unless total is 0 or covered/total is 1
      $('#change-coverage').on 'change', -> $fullCoverageRows().toggle()
    else
      $('.coverage-checkbox').hide()

  startMocha: ->
    mochaConfig = ui: 'bdd'
    mochaConfig.timeout = 0 unless window.PHANTOMJS # for easy debug in browser
    window.mocha.setup mochaConfig
    # Dynamically require all test files.
    $.ajax
      url: '../testSpecs.txt'
      dataType: 'text'
    .done (data) ->
      specList = data.split '\n'
      # Remove blank line from end.
      specList.pop()
      specs = $.map specList, (spec) -> spec.replace '.coffee', ''
      require specs, -> window.mocha.run()
    .fail ->
      console.log 'Failure with loading spec list! ', arguments
