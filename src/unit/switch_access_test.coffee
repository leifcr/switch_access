create_switch_elements = (count, startnum) ->
  elements = []
  i = startnum
  while i <= (startnum + count)
    elements.push(create_switch_element(i))
    i++
  elements

create_switch_group_with_elements = (element_count, element_startnum, groupnum) ->
  group = create_switch_group(groupnum)
  group.append(create_switch_elements(element_startnum, element_count))
  group

create_switch_groups_with_elements = (group_count, startnum, element_count, element_start_number, start_at_zero_for_elements) ->
  groups = []
  i = startnum
  current_switch_element_startnum = element_startnum
  while i <= (startnum + group_count)
    groups.push(create_switch_group_with_elements(element_count, current_switch_element_startnum, i))
    current_switch_element_startnum += element_count unless start_at_zero_for_elements == true
    i++ 
  [groups, current_switch_element_startnum]

create_switch_element = (number) ->
  ret = $("<div />")
  ret.addClass("switch-element-#{number}").addClass("test-element").text("Switch Element #{number}")
  ret

create_switch_group = (number) ->
  ret = $("<div />")
  ret.addClass("switch-group-#{number}").addClass("test-group").text("Switch Group #{number}")
  ret

QUnit.module 'Two Switches, single elements', {
  setup: ->
    create_switch_elements(2,1)
    $('#qunit-fixture').prepend(create_switch_elements(3,1))

  teardown: ->
    $('.test-element').remove()
    $('.test-group').remove()
    return
  }

QUnit.test 'It should start at the first element', 1, ->
  return

QUnit.test 'It should move to the second element', 1, ->
  return

QUnit.test 'It should move to the third element', 1, ->
  return

QUnit.test 'It should move back to the first element', 1, ->
  return

QUnit.test 'It should move activate the first element', 1, ->
  return
