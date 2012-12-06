QUnit.module 'One Switch, single elements', {
  setup: ->
    elements = Helper.create_switch_elements(1, 3)
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

QUnit.test 'It should start at the first element', 2, ->
  equal $('.switch-element-1').hasClass('switch-element-1'), true
  equal $('.switch-element-1').hasClass('current'), true
  return

QUnit.test 'It should move to the second element', 1, ->
  stop()
  setTimeout(( -> 
    equal $('.switch-element-2').hasClass('current'), true
    start())
    , 125)
  return

QUnit.test 'It should move to the third element', 1, ->
  stop()
  setTimeout(( -> 
    equal $('.switch-element-3').hasClass('current'), true
    start())
    , 225)
  return

QUnit.test 'It should move back to the first element', 1, ->
  stop()
  setTimeout(( -> 
    equal $('.switch-element-1').hasClass('current'), true
    start())
    , 325)
  return

QUnit.test 'It should activate the link within the first element', 2, ->
  equal $('.switch-element-1').hasClass('current'), true
  Helper.trigger_key_event(13)
  console.log(document.URL)
  equal /#switch-element-1/.test(document.URL), true
  return

QUnit.test 'It should activate the link within the second element', 2, ->
  stop()
  setTimeout(( -> 
    Helper.trigger_key_event(13)
    equal $('.switch-element-2').hasClass('current'), true
    equal /#switch-element-2/.test(document.URL), true
    start())
    , 125)
  return
