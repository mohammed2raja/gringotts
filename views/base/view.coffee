import Chaplin from 'chaplin'
import Templatable from '../../mixins/views/templatable'
import ErrorHandling from '../../mixins/views/error-handling'

export default class View extends ErrorHandling Templatable Chaplin.View
  autoRender: yes
