require 'lib/view-helper'

module.exports =
  lib:
    MixinBuilder: require 'lib/mixin-builder'
    deadDeferred: require 'lib/dead-deferred'
    mixinHelper: require 'lib/mixin-helper'
    swissAjax: require 'lib/swiss-ajax'
    utils: require 'lib/utils'
  mixins:
    models:
      Abortable: require 'mixins/models/abortable'
      ActiveSyncMachine: require 'mixins/models/active-sync-machine'
      ErrorHandled: require 'mixins/models/error-handled'
      ForcedReset: require 'mixins/models/forced-reset'
      Paginated: require 'mixins/models/paginated'
      Queryable: require 'mixins/models/queryable'
      SafeSyncCallback: require 'mixins/models/safe-sync-callback'
      Sorted: require 'mixins/models/sorted'
      SyncDeeply: require 'mixins/models/sync-deeply'
      SyncKey: require 'mixins/models/sync-key'
      Validatable: require 'mixins/models/validatable'
      WithHeaders: require 'mixins/models/with-headers'
    views:
      Classy: require 'mixins/views/classy'
      Content: require 'mixins/views/content'
      Editable: require 'mixins/views/editable'
      ErrorHandling: require 'mixins/views/error-handling'
      Filtering: require 'mixins/views/filtering'
      GenericSave: require 'mixins/views/generic-save'
      Paginating: require 'mixins/views/paginating'
      Routing: require 'mixins/views/routing'
      ServiceErrorReady: require 'mixins/views/service-error-ready'
      Sorting: require 'mixins/views/sorting'
      StateBindable: require 'mixins/views/state-bindable'
      Templatable: require 'mixins/views/templatable'
      Validating: require 'mixins/views/validating'
  models:
    base:
      Collection: require 'models/base/collection'
      Model: require 'models/base/model'
    FilterSelection: require 'models/filter-selection'
    Notifications: require 'models/notifications'
  views:
    base:
      CollectionView: require 'views/base/collection-view'
      ModalView: require 'views/base/modal-view'
      View: require 'views/base/view'
    DialogView: require 'views/dialog-view'
    FilterInputView: require 'views/filter-input-view'
    NotificationView: require 'views/notification-view'
    NotificationsView: require 'views/notifications-view'
    ProgressDialogView: require 'views/progress-dialog-view'
