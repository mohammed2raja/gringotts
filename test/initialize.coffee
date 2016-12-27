require ['../config', 'config'], ->
  require ['test/helpers/init-helper'], (initHelper) ->
    initHelper.initMochaBlanket ->
      require ['chai', 'sinon-chai', 'chai-jquery', 'test/dependencies'],
        (chai, sinonChai, chaiJquery) ->
          chai.use sinonChai
          chai.use chaiJquery
          window.expect = chai.expect
          initHelper.setupUI()
          initHelper.startMocha()
