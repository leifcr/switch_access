QUnit.module 'Two Switches, 2 groups with 3 elements', {
  setup: ->
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

QUnit.test 'It should start at the first group and the groups children should be marked as "current"', 1, ->
  equal $('.switch-element-1.test-group').find("[class*=switch-element-]").hasClass('current'), true
  return

QUnit.test 'It should move to the second group', 1, ->
  Helper.trigger_key_event(32)
  equal $('.switch-element-2.test-group').find("[class*=switch-element-]").hasClass('current'), true
  return

QUnit.test 'It should go inside the first group', 3, ->
  Helper.trigger_key_event(13)
  equal $('.switch-element-1.test-group').find(".switch-element-1").hasClass('current'), true
  equal $('.switch-element-1.test-group').find(".switch-element-2").hasClass('current'), false
  equal $('.switch-element-1.test-group').find(".switch-element-3").hasClass('current'), false
  return

QUnit.test 'It should move through the three child elements in the first group', 9, ->
  Helper.trigger_key_event(13)
  equal $('.switch-element-1.test-group').find(".switch-element-1").hasClass('current'), true
  equal $('.switch-element-1.test-group').find(".switch-element-2").hasClass('current'), false
  equal $('.switch-element-1.test-group').find(".switch-element-3").hasClass('current'), false
  Helper.trigger_key_event(32)
  equal $('.switch-element-1.test-group').find(".switch-element-1").hasClass('current'), false
  equal $('.switch-element-1.test-group').find(".switch-element-2").hasClass('current'), true
  equal $('.switch-element-1.test-group').find(".switch-element-3").hasClass('current'), false
  Helper.trigger_key_event(32)
  equal $('.switch-element-1.test-group').find(".switch-element-1").hasClass('current'), false
  equal $('.switch-element-1.test-group').find(".switch-element-2").hasClass('current'), false
  equal $('.switch-element-1.test-group').find(".switch-element-3").hasClass('current'), true
  return


QUnit.test 'It should move back to the group and highlight the three children', 4, ->
  # trigger keypress "space" twice
  Helper.trigger_key_event(13)
  equal $('.switch-element-1.test-group').find(".switch-element-1").hasClass('current'), true
  equal $('.switch-element-1.test-group').find(".switch-element-2").hasClass('current'), false
  equal $('.switch-element-1.test-group').find(".switch-element-3").hasClass('current'), false
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(32)
  equal $('.switch-element-1.test-group').find("[class*=switch-element-]").hasClass('current'), true
  return

QUnit.test 'It should activate the link on the third element in the second group', 1, ->
  # trigger keypress "space" twice
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(13)
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(32)
  Helper.trigger_key_event(13)
  equal /#group-2-switch-element-3/.test(document.URL), true
  return
