import helper from '../../lib/mixin-helper'
import ActiveSyncMachine from '../../mixins/models/active-sync-machine'
import SafeSyncCallback from '../../mixins/models/safe-sync-callback'
import ErrorHandled from '../../mixins/models/error-handled'
import Abortable from '../../mixins/models/abortable'
import WithHeaders from '../../mixins/models/with-headers'
import Collection from './collection'

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
