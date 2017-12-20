import Chaplin from 'chaplin'
import ActiveSyncMachine from '../../mixins/models/active-sync-machine'
import Abortable from '../../mixins/models/abortable'
import SafeSyncCallback from '../../mixins/models/safe-sync-callback'
import ErrorHandled from '../../mixins/models/error-handled'
import WithHeaders from '../../mixins/models/with-headers'
import Model from './model'

###*
  *  Abstract class for collections. Includes useful mixins by default.
###
export default class Collection extends ActiveSyncMachine \
    ErrorHandled WithHeaders Abortable SafeSyncCallback Chaplin.Collection

  model: Model
