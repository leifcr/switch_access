QUnit.module 'One Switch, 2 groups with 3 elements', {
  setup: ->
    elements = Helper.create_switch_groups_with_elements(2, 1, 3, 1, true)
    $('#qunit-fixture').append(elements)
    @sw_access = new SwitchAccess({
      debug: false,
      switches: {
        number_of_switches: 1,
        delay_for_allowed_keypress: 0,
        single_switch_move_time: 100,
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

QUnit.test 'It should start at the first element', 1, ->
  equal $('.switch-element-1.test-group').find("[class*=switch-element-]").hasClass('current'), true
  return

QUnit.test 'It should move to the second element', 1, ->
  stop()
  setTimeout(( -> 
    equal $('.switch-element-2.test-group').find("[class*=switch-element-]").hasClass('current'), true
    start())
    , 125)
  return

QUnit.test 'It should move back to the first element', 1, ->
  stop()
  setTimeout(( -> 
    equal $('.switch-element-1.test-group').find("[class*=switch-element-]").hasClass('current'), true
    start())
    , 225)
  return
# Cannot test links in firefox/mozilla, but if callbacks work, links work
if typeof(jQuery.browser.mozilla) == "undefined"
  QUnit.test 'It should activate the first link in the first group', 2, ->
    equal $('.switch-element-1').hasClass('current'), true
    Helper.trigger_key_event(13)
    Helper.trigger_key_event(13)
    equal /#group-1-switch-element-1/.test(document.URL), true
    return

  QUnit.test 'It should activate the link on the third element in the second group', 5, ->
    # trigger keypress "space" twice
    stop()
    setTimeout(( -> 
      equal $('.switch-element-2.test-group').find("[class*=switch-element-]").hasClass('current'), true, "Group 1 child should all have current class"
      Helper.trigger_key_event(32)
      setTimeout(( ->
        equal $('.switch-element-2.test-group').find(".switch-element-1").hasClass('current'), false, "switch-element-1 should NOT be current"
        equal $('.switch-element-2.test-group').find(".switch-element-2").hasClass('current'), false, "switch-element-2 should NOT be current"
        equal $('.switch-element-2.test-group').find(".switch-element-3").hasClass('current'), true, "switch-element-3 should be current"
        Helper.trigger_key_event(32)
        console.log(document.URL)
        equal /#group-2-switch-element-3/.test(document.URL), true
        start())
        , 225)
      )
      , 125)  


    return
