utils = require 'lib/utils'
helpers = url: require 'templates/helpers/url'

describe 'URL helper', ->
  hbsOptions = null

  beforeEach ->
    sinon.stub utils, 'reverse', -> ''

  afterEach ->
    utils.reverse.restore()

  it 'should work without arguments', ->
    helpers.url {}
    expect(utils.reverse).to.be.calledOnce

  it 'should properly format URLs with params', ->
    helpers.url 'route', 'params', {}
    expect(utils.reverse).to.be.calledWith 'route', ['params']

  it 'should properly format URLs with params as object', ->
    helpers.url 'route', {p1:1, p2:2}, {}
    expect(utils.reverse).to.be.calledWith 'route', {p1:1, p2:2}

  it 'should properly format URLs with params as array', ->
    helpers.url 'route', ['param1', 'param2'], {}
    expect(utils.reverse).to.be.calledWith 'route', ['param1', 'param2']

  it 'should properly format URLs without params', ->
    helpers.url 'path', {}
    expect(utils.reverse).to.be.calledWith 'path'

  it 'should be able to be called without a query', ->
    helpers.url 'path', 5, {}
    expect(utils.reverse).to.be.calledWith 'path', [5]

  it 'should pass the query along', ->
    helpers.url 'starbuck', null, 'rank=lt', {}
    expect(utils.reverse).to.be.calledWith 'starbuck', null, 'rank=lt'

  it 'should pass the handlebars hash into query', ->
    helpers.url 'route', 5, null, hash: p1: 1
    expect(utils.reverse).to.be.calledWith 'route', [5], p1: 1
