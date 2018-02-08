import Chaplin from 'chaplin'
import utils from 'lib/utils'
import FilterSelection from 'models/filter-selection'
import FilterInputView from 'views/filter-input-view'

setQuery = (view, query) ->
  view.$('input').val(query).trigger $.Event 'keyup'

describe 'FilterInputView', ->
  sandbox = null
  collection = null
  groupSource = null
  view = null

  beforeEach ->
    sandbox = sinon.sandbox.create()
    collection = new FilterSelection [
      new Chaplin.Model
        groupId: 'group1'
        groupName: 'Group One'
        id: 'gp1item2'
        name: 'Second Item'
      new Chaplin.Model
        groupId: 'group2'
        groupName: 'Group Two'
        id: 'gp2item1'
        name: 'First Item'
      new Chaplin.Model
        groupId: 'group2'
        groupName: 'Group Two'
        id: 'gp2item2'
        name: 'Second Item'
        required: yes
    ]
    groupSource = new Chaplin.Collection [
      new Chaplin.Model
        id: 'group1'
        name: 'Group One'
        singular: yes
        children: new Chaplin.Collection [
          new Chaplin.Model id: 'gp1item1', name: 'First Item'
          new Chaplin.Model id: 'gp1item2', name: 'Second Item'
          new Chaplin.Model id: 'gp1item3', name: 'Third Item'
          new Chaplin.Model id: 'gp1item4', name: 'Forth 4 Item'
          new Chaplin.Model id: 'gp1item5', name: 'Fifth Item'
        ]
      new Chaplin.Model
        id: 'group2'
        name: 'Group Two'
        required: yes
        children: new Chaplin.Collection [
          new Chaplin.Model id: 'gp2item1', name: 'First Item'
          new Chaplin.Model id: 'gp2item2', name: 'Second Item'
        ]
      new Chaplin.Model
        id: 'group3'
        name: 'Group Three'
        children: new Chaplin.Collection()
      new Chaplin.Model
        id: 'q'
        name: 'Search'
        description: 'A leaf group for action filters, like search'
        action: yes
    ]
    sandbox.stub(_, 'debounce').callsFake (fn) -> fn
    view = new FilterInputView {
      collection
      groupSource
      placeholder: 'Filter items by...'
    }
    $('body').append view.$el

  afterEach ->
    sandbox.restore()
    view.$el.remove()
    view.dispose()
    collection.dispose()
    groupSource.dispose()

  it 'should have proper classes applied', ->
    expect(view.$el).to.have.class 'form-control'
    expect(view.$el).to.not.have.class 'focus'

  it 'should have placeholder set', ->
    expect(view.$ 'input').to.have.attr 'placeholder', 'Filter items by...'

  it 'should have dropdowns collapsed', ->
    expect(view.$ '.dropdown').to.not.have.class 'open'

  it 'should not render group label', ->
    expect(view.$ '.selected-group').to.be.empty

  it 'should render selected items', ->
    $selectedItems = view.$ '.selected-item'
    expect($selectedItems).to.have.length 3
    $selectedItems.each (i, el) ->
      model = collection.models[i]
      $el = $ el
      expect($el.find '.item-group').to.have.text model.get 'groupName'
      expect($el.find '.item-name').to.have.text model.get 'name'
      $removeButton = $el.find '.remove-button'
      if model.get 'required'
        expect($removeButton).to.not.exist
      else
        expect($removeButton).to.exist

  it 'should have remove all button visible', ->
    expect(view.$ '.remove-all-button').to.be.visible()

  context 'on selected item remove click', ->
    beforeEach ->
      view.$('.selected-item .remove-button').first().click()

    it 'should remove item from collection', ->
      expect(collection).to.have.length 2

    it 'should remove item from control', ->
      expect(view.$ '.selected-item').to.have.length 2

  context 'on remove all click', ->
    beforeEach ->
      view.$('.remove-all-button').click()

    it 'should remove all unrequired items from collection', ->
      expect(collection).to.have.length 1

    it 'should remove all items from control', ->
      expect(view.$ '.selected-item').to.have.length 1

    it 'should set remove all button hidden', ->
      expect(view.$ '.remove-all-button').to.be.hidden()

  context 'on finish loading children', ->
    beforeEach ->
      group3 = groupSource.findWhere id: 'group3'
      group3.get('children').add \
        new Chaplin.Model id: 'gp3item1', name: 'First Item of Group Three'
      group3.get('children').trigger 'synced'

    it 'should render group description', ->
      groupItems = view.$ '.dropdown-groups a'
      expect($(groupItems[2]).find '.item-description').to.have.text \
        'First Item of Group Three'

  getVisibleItems = (dropdown) ->
    items = view.$(".dropdown-#{dropdown} .filter-item:visible")

  expectInputFocused = ->
    it 'should have input focused', ->
      expect(view.$('input')[0] is document.activeElement).to.be.true

  expectOpenGroupsDropdown = ->
    it 'should show dropdown', ->
      expect(view.$ '.dropdown').to.have.class 'open'

    it 'should have groups dropdown visible', ->
      expect(view.$ '.dropdown-groups').to.not.have.class 'hidden'
      expect(view.$ '.dropdown-items').to.have.class 'hidden'

    it 'should have input empty', ->
      expect(view.$ 'input').to.be.empty

    it 'should add focus to the root element', ->
      expect(view.$el).to.have.class 'focus'

  expectDefaultGroupsInDropdown = ->
    it 'should render groups dropdown', ->
      $groupItems = view.$ '.dropdown-groups a:visible'
      expect($groupItems).to.have.length 4
      $groupItems.each (i, el) ->
        model = groupSource.models[i]
        $el = $ el
        expect($el.find '.item-name').to.have.text model.get 'name'
        expect($el.find '.item-name i').to.not.exist
        if model.id is 'group1'
          expect($el.find '.item-description').to.have
            .text 'First Item, Second Item, Third Item…'
        else if model.id is 'group2'
          expect($el.find '.item-description').to.have
            .text 'First Item or Second Item'
        else if model.id is 'group3'
          expect($el.find '.item-description').to.have.text 'Loading...'
        else
          expect($el.find '.item-description').to
            .have.text model.get 'description'
        if not model.get('children')?
          expect($el.parent 'li').to.have.class 'disabled no-hover'

  expectEmptyGroupsDropdown = ->
    it 'should render empty groups dropdown', ->
      visibleGroupItem = view.$('.dropdown-groups .filter-item:visible')
      expect(visibleGroupItem).to.have.length 1
      expect(visibleGroupItem.find('.item-name').text()).to.include 'Search'
      expect(view.$ '.dropdown-groups .filters-dropdown-loading')
        .to.be.hidden()

  expectEmptyItemsDropdown = ->
    it 'should render empty items dropdown', ->
      view.$('.dropdown-items .filter-item').each (i, el) ->
        expect($ el).to.be.hidden()
      expect(view.$ '.dropdown-items .filters-dropdown-empty').to.be.visible()

  expectFilteredGroupsDropdown = (query, groupNameInj='', groupDescInj='') ->
    it 'should filter groups dropdown', ->
      groupItems = getVisibleItems 'groups'
      expect(groupItems).to.have.length 2
      group0 = $ groupItems[0]
      group1 = $ groupItems[1]
      expect(group0.find '.item-name').to.have.text 'Group One'
      expect(group0.find '.item-name i').to.have.text groupNameInj
      expect(group0.find '.item-description i').to.have.text groupDescInj
      expect(group1.find '.item-name').to.have.text 'Search'
      expect(group1.find '.item-note').to.have.text query
      expect(group1).to.not.have.class 'disabled no-hover'

  expectOpenItemsDropdown = ->
    it 'should show dropdown', ->
      expect(view.$ '.dropdown').to.have.class 'open'

    it 'should have items dropdown visible', ->
      expect(view.$ '.dropdown-groups').to.have.class 'hidden'
      expect(view.$ '.dropdown-items').to.not.have.class 'hidden'

    it 'should have input empty', ->
      expect(view.$ 'input').to.be.empty

  expectDefaultItemsDropdown = ->
    it 'should render group label', ->
      expect(view.$ '.selected-group').to.have.text 'Group One'

    it 'should render items dropdown', ->
      $items = view.$ '.dropdown-items a'
      expect($items).to.have.length 4
      expect($items.first().find '.item-name').to.have.text 'First Item'
      expect($items.last().find '.item-name').to.have.text 'Fifth Item'

  expectClosedDropdowns = ->
    it 'should hide dropdown', ->
      expect(view.$ '.dropdown').to.not.have.class 'open'

  expectFocusedState = ->
    it 'should have root element with focus', ->
      expect(view.$el).to.have.class 'focus'

  expectItemSelected = (groupName, itemName) ->
    it 'should render the item in selection', ->
      $lastSelectedItem = view.$('.selected-item').last()
      expect($lastSelectedItem.find '.item-group').to.have.text groupName
      expect($lastSelectedItem.find '.item-name').to.have.text itemName

  context 'on whitespace click', ->
    beforeEach ->
      view.$('.filter-items-container').click()

    expectOpenGroupsDropdown()

  context 'on input click', ->
    beforeEach ->
      view.$('input').click()

    expectOpenGroupsDropdown()
    expectDefaultGroupsInDropdown()

    context 'on input esc', ->
      beforeEach ->
        view.$('input').focus().trigger $.Event 'keydown',
          which: utils.keys.ESC

      expectClosedDropdowns()
      expectFocusedState()

      context 'on type char', ->
        beforeEach ->
          view.$('input').trigger $.Event 'keydown', which: 100

        expectOpenGroupsDropdown()

    context 'on "Group One" item click', ->
      beforeEach ->
        view.$('.dropdown-groups a').first().click()

      expectOpenItemsDropdown()
      expectDefaultItemsDropdown()

      context 'on "Fifth Item" click', ->
        beforeEach ->
          view.$('.dropdown-items a').last().click()

        expectClosedDropdowns()
        expectFocusedState()
        expectItemSelected 'Group One', 'Fifth Item'

        it 'should update collection', ->
          expect(collection.where groupId: 'group1').to.have.length 1
          expect(collection.last().attributes).to.eql {
            groupId: 'group1'
            groupName: 'Group One'
            id: 'gp1item5'
            name: 'Fifth Item'
          }

        context 'on input delete', ->
          beforeEach ->
            view.$('input').click().trigger $.Event 'keydown',
              which: utils.keys.DELETE

          it 'should remove last unrequired item from collection', ->
            expect(collection).to.have.length 2
            expect(collection.last().attributes).to.include {
              id: 'gp2item2'
              name: 'Second Item'
            }

          context 'on input delete again', ->
            beforeEach ->
              view.$('input').click().trigger $.Event 'keydown',
                which: utils.keys.DELETE

            it 'should remote last unrequired item from collection', ->
              expect(collection).to.have.length 1
              expect(collection.last().attributes).to.include {
                id: 'gp2item2'
                name: 'Second Item'
              }

    context 'on "Group Two" item click', ->
      beforeEach ->
        view.$('.dropdown-groups a')[1].click()

      it 'should render group label', ->
        expect(view.$ '.selected-group').to.have.text 'Group Two'

      expectEmptyItemsDropdown()

    context 'on "Search" group item click', ->
      beforeEach ->
        setQuery view, 'needle'
        view.$('.dropdown-groups a').last().click()

      it 'should not render group label', ->
        expect(view.$ '.selected-group').to.be.empty

      expectClosedDropdowns()
      expectItemSelected 'Search', 'needle'

  context 'on input enter', ->
    beforeEach ->
      view.$('input').focus().trigger $.Event 'keydown',
        which: utils.keys.ENTER

    expectOpenGroupsDropdown()

    context 'on type text', ->
      text = null

      beforeEach ->
        setQuery view, text

      context 'existing group name', ->
        before ->
          text = 'group o'

        expectFilteredGroupsDropdown 'group o', 'Group O'

        context 'on enter key press', ->
          beforeEach ->
            view.$('input').trigger $.Event 'keydown',
              which: utils.keys.ENTER

          expectOpenItemsDropdown()
          expectInputFocused()

          it 'should select group', ->
            expect(view.$ '.selected-group').to.have.text 'Group One'

          context 'on type existing item text', ->
            beforeEach ->
              setQuery view, 'thi'

            it 'should filter items dropdown', ->
              items = getVisibleItems 'items'
              expect(items).to.have.length 1
              item0 = $ items[0]
              expect(item0.find '.item-name').to.have.text 'Third Item'
              expect(item0.find '.item-name i').to.have.text 'Thi'

            context 'on enter key press', ->
              beforeEach ->
                view.$('input').trigger $.Event 'keydown',
                  which: utils.keys.ENTER

              expectItemSelected 'Group One', 'Third Item'
              expectInputFocused()

          context 'on type random text', ->
            beforeEach ->
              setQuery view, 'qwerty'

            expectEmptyItemsDropdown()

            context 'on esc key press', ->
              beforeEach ->
                view.$('input').trigger $.Event 'keydown',
                  which: utils.keys.ESC

              it 'should clear selected group', ->
                expect(view.$ '.selected-group').to.be.empty

              expectOpenGroupsDropdown()
              expectDefaultGroupsInDropdown()
              expectInputFocused()

        context 'on text clear', ->
          beforeEach ->
            setQuery view, ''

          expectDefaultGroupsInDropdown()

      context 'existing group child name', ->
        before ->
          text = 'Fif'

        it 'should add "Fifth Item" into description', ->
          group = $ _.first getVisibleItems 'groups'
          expect(group.find('.item-description').text()).to
            .include 'Fifth Item'

        expectFilteredGroupsDropdown 'Fif', '', 'Fif'

        context 'on enter key press', ->
          beforeEach ->
            view.$('input').trigger $.Event 'keydown',
              which: utils.keys.ENTER

          expectItemSelected 'Group One', 'Fifth Item'
          expectInputFocused()

      context 'number in existing group child name', ->
        before ->
          text = '4'

        it 'should add "Forth Item" into description', ->
          group = $ _.first getVisibleItems 'groups'
          expect(group.find('.item-description').text()).to
            .include 'Forth 4 Item'

        expectFilteredGroupsDropdown '4', '', '4'

      context 'random text', ->
        before ->
          text = 'asdfgh'

        expectEmptyGroupsDropdown()

        context 'on input enter', ->
          beforeEach ->
            view.$('input').focus().trigger $.Event 'keydown',
              which: utils.keys.ENTER

          expectDefaultGroupsInDropdown()
          expectInputFocused()
          expectItemSelected 'Search', 'asdfgh'

        context 'on delete text', ->
          beforeEach ->
            setQuery view, ''

          expectOpenGroupsDropdown()
          expectDefaultGroupsInDropdown()
          expectInputFocused()

    context 'on down key press', ->
      beforeEach ->
        view.$('input').trigger $.Event 'keydown',
          which: utils.keys.DOWN

      it 'should focus dropdown first group', ->
        $first = view.$('.dropdown-groups a').first()
        expect($first.find '.item-name').to.have.text 'Group One'
        expect($first[0] is document.activeElement).to.be.true

      context 'on click input back', ->
        beforeEach ->
          view.$('input').click()

        expectOpenGroupsDropdown()

      context 'on enter key press', ->
        beforeEach ->
          $(document.activeElement)
            .trigger($.Event 'keydown', which: utils.keys.ENTER)
            .click()

        expectDefaultItemsDropdown()

        context 'on down key press', ->
          beforeEach ->
            view.$('input').trigger $.Event 'keydown',
              which: utils.keys.DOWN

          it 'should focus dropdown first item', ->
            $first = view.$('.dropdown-items a').first()
            expect($first.find '.item-name').to.have.text 'First Item'
            expect($first[0] is document.activeElement).to.be.true

          context 'on enter key press', ->
            beforeEach ->
              $(document.activeElement)
                .trigger($.Event 'keydown', which: utils.keys.ENTER)
                .click()

            expectItemSelected 'Group One', 'First Item'
            expectInputFocused()

    context 'on up key press', ->
      beforeEach ->
        view.$('input').trigger $.Event 'keydown',
          which: utils.keys.UP

      it 'should focus dropdown last item', ->
        $last = view.$('.dropdown-groups a').last()
        expect($last.find '.item-name').to.have.text 'Search'
        expect($last[0] is document.activeElement).to.be.true

    context 'on click elsewhere', ->
      beforeEach ->
        setQuery view, 'abc'
        $(document).trigger 'click.bs.dropdown.data-api'

      expectClosedDropdowns()

      it 'should remove focus from the root element', ->
        expect(view.$el).to.not.have.class 'focus'

      it 'should clear input', ->
        expect(view.$ 'input').to.be.empty
