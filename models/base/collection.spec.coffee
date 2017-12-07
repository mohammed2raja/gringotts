helper = require 'lib/mixin-helper'
ActiveSyncMachine = require 'mixins/models/active-sync-machine'
SafeSyncCallback = require 'mixins/models/safe-sync-callback'
ErrorHandled = require 'mixins/models/error-handled'
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
    expect(helper.instanceWithMixin collection, ErrorHandled).to.be.true
    expect(helper.instanceWithMixin collection, Abortable).to.be.true
    expect(helper.instanceWithMixin collection, WithHeaders).to.be.true
