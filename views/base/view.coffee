Chaplin = require 'chaplin'
Templatable = require '../../mixins/views/templatable'
ErrorHandling = require '../../mixins/views/error-handling'

module.exports = class View extends ErrorHandling Templatable Chaplin.View
  autoRender: yes
