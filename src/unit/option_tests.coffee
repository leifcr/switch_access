QUnit.module 'Options tests', {
  setup: ->
    @option_events = {
      activate: 0
      move: 0
      enter_group: 0
      leave_group: 0
      idx: 0
    }
    return

  teardown: ->
    @sw_access.destroy()
    return
  }

QUnit.test 'It should not allow keypresses before delay has timed out', 10, ->
  elements = Helper.create_switch_elements(1, 2)
  $('#qunit-fixture').append(elements)
  @sw_access = new SwitchAccess({
    debug: false,
    switches: {
      number_of_switches: 2,
      delay_for_allowed_keypress: 250,
    },
    visual: {
      ensure_visible_element: false
    }
    })
  stop()

  $('.switch-element-1').on("switch-access-move", (event, param1, param2, param3) =>
    equal param1, 0, "the index should be 0"
    equal param2, 0, "the level should be 0"
    @option_events.move++
    equal @option_events.move, 2, "should have moved twice, moving back to switch-element-1"
    )
  $('.switch-element-2').on("switch-access-move", (event, param1, param2, param3) =>
    equal param1, 1, "the index should be 1"
    equal param2, 0, "the level should be 0"
    @option_events.move++
    equal @option_events.move, 1, "should have moved once, moving to switch-element-2"
    )
  Helper.trigger_key_event(32)
  setTimeout(( => 
    Helper.trigger_key_event(32)
    equal @option_events.move, 1, "after 25 ms it should have moved once, blocking keypresses" 
    )
    , 25)
  setTimeout(( => 
    Helper.trigger_key_event(32)
    equal @option_events.move, 1, "after 50 ms it should have moved once, blocking keypresses" 
    )
    , 50)
  setTimeout(( => 
    Helper.trigger_key_event(32)
    equal @option_events.move, 1, "after 75 ms it should have moved once, blocking keypresses"  
    )
    , 75)
  setTimeout(( => 
    Helper.trigger_key_event(32)
    )
    , 275)
  setTimeout(( => 
    equal @option_events.move, 2, "should have moved twice"
    $('.switch-element-1').off("switch-access-move")
    $('.switch-element-2').off("switch-access-move")
    start()
    )
    , 300)
  return


QUnit.test 'It should not use groups, even if groups are on the page', 14, ->
  elements = Helper.create_switch_groups_with_elements(2, 1, 3, 1, true)
  $('#qunit-fixture').append(elements)
  @sw_access = new SwitchAccess({
    debug: false,
    switches: {
      number_of_switches: 2,
      delay_for_allowed_keypress: 0,
      groups: false,
    },
    visual: {
      ensure_visible_element: false
    }
    })

  stop()

  $('[class*=switch-element-]').on("switch-access-enter-group", (event, param1, param2, param3) =>
    @option_events.enter_group++
    return
    )

  $('[class*=switch-element-]').on("switch-access-leave-group", (event, param1, param2, param3) =>
    @option_events.leave_group++
    return
    )

  $('[class*=switch-element-]').on("switch-access-move", (event, param1, param2, param3) =>
    @option_events.idx++
    @option_events.move++
    equal param2, 0, "The level should be 0"
    equal param1, @option_events.idx, "The index should be #{@option_events.idx}"
    return
    )

  $('[class*=switch-element-]').on("switch-access-activate", (event, param1, param2, param3) =>
    # console.log "activate", param1, param2, param3
    @option_events.activate++
    return
    )

  Helper.trigger_key_event(13)
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(13)
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(13)
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(32)
  $('[class*=switch-element-]').off("switch-access-activate")
  $('[class*=switch-element-]').off("switch-access-move")
  $('[class*=switch-element-]').off("switch-access-enter-group")
  $('[class*=switch-element-]').off("switch-access-leave-group")

  setTimeout(( => 
    equal @option_events.enter_group, 0, "No groups should have been entered"
    equal @option_events.leave_group, 0, "No groups should have been left"
    equal @option_events.activate, 3, "3 activations should have been triggered"
    equal @option_events.move, 5, "5 moves should have been triggered"
    start()
    )
    , 50)


  return

