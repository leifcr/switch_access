QUnit.module 'Callback test - Two Switches, 2 groups with 3 elements', {
  setup: ->
    @callbacks = {
      activate: 0
      move: 0
      enter_group: 0
      leave_group: 0
      idx: 0
    }
    elements = Helper.create_switch_groups_with_elements(2, 1, 3, 1, true)
    $('#qunit-fixture').append(elements)
    @sw_access = new SwitchAccess({
      debug: false,
      switches: {
        number_of_switches: 2,
        delay_for_allowed_keypress: 0,
      },
      visual: {
        ensure_visible_element: false;
      }
      })
    if @sw_access.options.debug
      $('#outerlogger').show()
    return

  teardown: ->
    @sw_access.destroy()
    return
  }

QUnit.test 'It should have one callback for moving to the second group', 3, ->
  stop()
  $('.switch-element-2.test-group').on("switch-access-move", (event, param1, param2, param3) =>
    equal param1, 1, "the index should be 1"
    equal param2, 0, "the level should be 0"
    @callbacks.move++
    equal @callbacks.move, 1
    $('.switch-element-2.test-group').off("switch-access-move")
    start()
    )
  Helper.trigger_key_event(32)
  return

QUnit.test 'It should have two callbacks for moving to the second group and back', 6, ->
  stop()
  $('.switch-element-1.test-group').on("switch-access-move", (event, param1, param2, param3) =>
    equal param1, 0, "the index should be 1"
    equal param2, 0, "the level should be 0"
    @callbacks.move++
    equal @callbacks.move, 2
    $('.switch-element-1.test-group').off("switch-access-move")
    start()
    )
  $('.switch-element-2.test-group').on("switch-access-move", (event, param1, param2, param3) =>
    equal param1, 1, "the index should be 1"
    equal param2, 0, "the level should be 0"
    @callbacks.move++
    equal @callbacks.move, 1
    $('.switch-element-2.test-group').off("switch-access-move")
    )
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(32)
  return

QUnit.test 'It should trigger enter group and leave group callbacks + callbacks moving inside the group', 11, ->
  stop()
  $('.switch-element-1.test-group').on("switch-access-enter-group", (event, param1, param2, param3) =>
    equal param1, 0, "Entered Group: the index should be 0"
    equal param2, 1, "Entered Group: the level should be 1" # callback is after the group is entered
    $('.switch-element-1.test-group').off("switch-access-enter-group")
    @callbacks.enter_group++
    )
  $('.switch-element-1.test-group').on("switch-access-leave-group", (event, param1, param2, param3) =>
    @callbacks.leave_group++
    equal param1, 0, "Left Group: the index should be 0"
    equal param2, 0, "Left Group: the level should be 0" # callback is after the group has been left
    equal @callbacks.move, 2, "Left Group: Should have moved twice before leaving groups" # moved two times to get out of the group
    equal @callbacks.enter_group, 1, "Left Group: Should have entered 1 group"
    equal @callbacks.leave_group, 1, "Left Group: Should have left 1 group"
    $('.switch-element-1.test-group').off("switch-access-leave-group")
    $('.switch-element-1.test-group').find('[class*=switch-element-]').off("switch-access-move")
    start()
    )
  $('.switch-element-1.test-group').find('[class*=switch-element-]').on("switch-access-move", (event, param1, param2, param3) =>
    @callbacks.move++
    @callbacks.idx++
    equal param1, @callbacks.idx, "Inside Group: the child index should be #{@callbacks.idx}"
    equal param2, 1, "Inside Group: the level should be 1"
    )
  Helper.trigger_key_event(13)
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(32)
  return


QUnit.test 'It should have one callback for activating an element', 2, ->
  stop()
  $('.switch-element-1').on("switch-access-activate", (event, param1, param2, param3) =>
    equal param1, 0, "the index should be 0"
    equal param2, 1, "the level should be 1"
    $('.switch-element-1').off("switch-access-activate")
    start()
    )
  Helper.trigger_key_event(13)
  Helper.trigger_key_event(13)
  return
