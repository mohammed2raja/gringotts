define (require) ->
  helper = require 'lib/mixin-helper'
  ActiveSyncMachine = require 'mixins/models/active-sync-machine'
  SafeSyncCallback = require 'mixins/models/safe-sync-callback'
  ServiceErrorCallback = require 'mixins/models/service-error-callback'
  Abortable = require 'mixins/models/abortable'
  WithHeaders = require 'mixins/models/with-headers'
  Collection = require 'models/base/collection'

  describe 'Base Collection', ->
    collection = null

    beforeEach ->
      collection = new Collection()

    afterEach ->
      collection.dispose()

    it 'should have proper mixins applied', ->
      expect(helper.instanceWithMixin collection, ActiveSyncMachine).to.be.true
      expect(helper.instanceWithMixin collection, SafeSyncCallback).to.be.true
      expect(helper.instanceWithMixin collection, ServiceErrorCallback)
        .to.be.true
      expect(helper.instanceWithMixin collection, Abortable).to.be.true
      expect(helper.instanceWithMixin collection, WithHeaders).to.be.true
