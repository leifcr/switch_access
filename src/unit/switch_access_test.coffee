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
  ret.addClass("switch-element-#{number}").addClass("test-group").text("Switch Group #{number}")
  ret

trigger_key_event = (key_code) -> 
  # trigger event
  event = $.Event( "keypress" );
  event.keyCode = key_code;
  $( document ).trigger( event );

QUnit.module 'Two Switches, single elements', {
  setup: ->
    elements = create_switch_elements(3,1)
    console.log elements
    $('#qunit-fixture').prepend(elements)
    new SwitchAccess({
      debug: false,
      number_of_switches: 2,
      })
    return

  teardown: ->
    # $('.test-element').remove()
    # $('.test-group').remove()
    return
  }

QUnit.test 'It should start at the first element', 1, ->
  equal $('.switch-element-1').hasClass('current'), true
  return

# QUnit.asyncTest 'It should move to the second element', 1, ->
#   # trigger keypress "space"
#   trigger_key_event(32)
#   setTimeout(( -> 
#     equal $('.switch-element-2').hasClass('current'), true
#     start())
#     , 75)
#   return

# QUnit.asyncTest 'It should move to the third element', 1, ->
#   # trigger keypress "space"
#   trigger_key_event(32)
#   setTimeout(( -> 
#     equal $('.switch-element-2').hasClass('current'), true
#     start())
#     , 75)
#   return

# QUnit.test 'It should move back to the first element', 1, ->
#   return

# QUnit.test 'It should move activate the first element', 1, ->
#   return
