import _icon from 'templates/helpers/icon'

describe 'icon helper', ->
  icon = null
  first = null
  second = null

  beforeEach ->
    icon = _icon first or 'triangle', second or undefined

  afterEach ->
    icon = null

  it 'should create HTML element', ->
    expect($ icon.string).to.have.class 'icon-triangle'

  context 'with a string', ->
    before -> second = 'rectangle'
    after -> second = null

    it 'should add classes', ->
      expect($ icon.string).to.have.class 'rectangle'

  context 'with an object', ->
    before ->
      second = title: 'My Title'

    after ->
      second = null

    it 'should add attributes', ->
      expect($ icon.string).to.have.attr 'title', 'My Title'

  context 'with a complex name', ->
    before -> first = 'my   sweet dreamy circle'
    after -> first = null

    it 'should add all classes', ->
      expect($ icon.string).to.have.class('my').and.have.class('sweet')
        .and.have.class('dreamy').and.have.class('icon-circle')

  it 'should return nothing if name is not set', ->
    icon = _icon()
    expect(icon).to.be.undefined
