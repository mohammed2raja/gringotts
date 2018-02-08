import utils from 'lib/utils'
import url from 'templates/helpers/url'

describe 'URL helper', ->
  hbsOptions = null

  beforeEach ->
    sinon.stub(utils, 'reverse').callsFake -> ''

  afterEach ->
    utils.reverse.restore()

  it 'should work without arguments', ->
    url {}
    expect(utils.reverse).to.be.calledOnce

  it 'should properly format URLs with params', ->
    url 'route', 'params', {}
    expect(utils.reverse).to.be.calledWith 'route', ['params']

  it 'should properly format URLs with params as object', ->
    url 'route', {p1:1, p2:2}, {}
    expect(utils.reverse).to.be.calledWith 'route', {p1:1, p2:2}

  it 'should properly format URLs with params as array', ->
    url 'route', ['param1', 'param2'], {}
    expect(utils.reverse).to.be.calledWith 'route', ['param1', 'param2']

  it 'should properly format URLs without params', ->
    url 'path', {}
    expect(utils.reverse).to.be.calledWith 'path'

  it 'should be able to be called without a query', ->
    url 'path', 5, {}
    expect(utils.reverse).to.be.calledWith 'path', [5]

  it 'should pass the query along', ->
    url 'starbuck', null, 'rank=lt', {}
    expect(utils.reverse).to.be.calledWith 'starbuck', null, 'rank=lt'

  it 'should pass the handlebars hash into query', ->
    url 'route', 5, null, hash: p1: 1
    expect(utils.reverse).to.be.calledWith 'route', [5], p1: 1
