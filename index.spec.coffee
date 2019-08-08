import 'core-js/stable'
import jQuery from 'jquery'
import 'bootstrap/js/button'
import 'bootstrap/js/collapse'
import 'bootstrap/js/dropdown'
import 'bootstrap/js/modal'
import 'bootstrap/js/tab'
import 'bootstrap/js/tooltip'
import 'bootstrap/js/transition'
import sinon, {FakeXMLHttpRequest} from 'sinon'
import chai from 'chai'
import sinonChai from 'sinon-chai'
import jqueryChai from 'chai-jquery'

jQuery.ajaxSetup async: no # https://github.com/sinonjs/sinon/issues/1637
FakeXMLHttpRequest::async = no

window.sinon = sinon

chai.use sinonChai
chai.use jqueryChai
chai.config.truncateThreshold = 0 # render full objects on deep equal errors
window.expect = chai.expect

testContext = require.context './', true, /\.spec\.coffee$/
testContext.keys().forEach testContext
