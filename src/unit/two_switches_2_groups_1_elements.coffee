QUnit.module 'Two Switches, 2 groups with 1 element', {
  setup: ->
    elements = Helper.create_switch_groups_with_elements(2, 1, 1, 1, true)
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

# Cannot test links in firefox/mozilla, but if callbacks work, links work
if typeof(jQuery.browser.mozilla) == "undefined"
  QUnit.test 'It should activate the first element in the group', 1, ->
    Helper.trigger_key_event(13)
    equal /#group-1-switch-element-1/.test(document.URL), true, "The url should contain #group-1-switch-element-1"
    return

  QUnit.test 'It should activate the first element in the second group', 2, ->
    Helper.trigger_key_event(32)
    equal $('.switch-element-2.test-group').find("[class*=switch-element-]").hasClass('current'), true
    Helper.trigger_key_event(13)
    equal /#group-2-switch-element-1/.test(document.URL), true, "The url should contain #group-2-switch-element-1"
    return
