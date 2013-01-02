QUnit.module 'One Switch, single elements, stay at element', {
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

QUnit.test 'It should start at the first element', 4, ->
  equal $('.switch-element-1').hasClass('current'), true
  equal $($('.highlighter')[0]).hasClass('current'), true
  equal $($('.highlighter')[1]).hasClass('current'), false
  equal $($('.highlighter')[2]).hasClass('current'), false
  return

QUnit.test 'It should move to the second element and stay there', 8, ->
  stop()
  $('.switch-element-2').attr("data-sw-single-stay", true)
  setTimeout(( -> 
    equal $('.switch-element-2').hasClass('current'), true,  "Switch element 2 should have current class"
    equal $($('.highlighter')[0]).hasClass('current'), false, "Highlighter 0 should not have current class"
    equal $($('.highlighter')[1]).hasClass('current'), true,  "Highlighter 1 should have current class"
    equal $($('.highlighter')[2]).hasClass('current'), false, "Highlighter 2 should not have current class"
    )
    , 125)
  setTimeout(( -> 
    equal $('.switch-element-2').hasClass('current'), true,   "Switch element 2 should have current class"
    equal $($('.highlighter')[0]).hasClass('current'), false, "Highlighter 0 should not have current class"
    equal $($('.highlighter')[1]).hasClass('current'), true,  "Highlighter 1 should have current class"
    equal $($('.highlighter')[2]).hasClass('current'), false, "Highlighter 2 should not have current class"
    start())
    , 225)
  return

QUnit.test 'It should move to the second element and stay there, then move to next on keypress', 12, ->
  stop()
  $('.switch-element-2').attr("data-sw-single-stay", true)
  $('.switch-element-2').attr("data-sw-single-noaction", true)
  setTimeout(( -> 
    equal $('.switch-element-2').hasClass('current'), true,  "Switch element 2 should have current class"
    equal $($('.highlighter')[0]).hasClass('current'), false, "Highlighter 0 should not have current class"
    equal $($('.highlighter')[1]).hasClass('current'), true,  "Highlighter 1 should have current class"
    equal $($('.highlighter')[2]).hasClass('current'), false, "Highlighter 2 should not have current class"
    )
    , 125)
  setTimeout(( -> 
    equal $('.switch-element-2').hasClass('current'), true,   "Switch element 2 should have current class"
    equal $($('.highlighter')[0]).hasClass('current'), false, "Highlighter 0 should not have current class"
    equal $($('.highlighter')[1]).hasClass('current'), true,  "Highlighter 1 should have current class"
    equal $($('.highlighter')[2]).hasClass('current'), false, "Highlighter 2 should not have current class"
    Helper.trigger_key_event(13)
    setTimeout(( -> 
      equal $('.switch-element-3').hasClass('current'), true,  "Switch element 3 should have current class"
      equal $($('.highlighter')[0]).hasClass('current'), false, "Highlighter 0 should not have current class"
      equal $($('.highlighter')[1]).hasClass('current'), false, "Highlighter 1 should not have current class"
      equal $($('.highlighter')[2]).hasClass('current'), true,  "Highlighter 2 should have current class"
      start())
      , 20)
    )
    , 225)
  return

QUnit.test 'It should move to the second element and stay there, then trigger action on keypress', 4, ->
  stop()
  $('.switch-element-2').attr("data-sw-single-stay", true)
  setTimeout(( -> 
    equal $('.switch-element-2').hasClass('current'), true,  "Switch element 2 should have current class"
    )
    , 125)
  setTimeout(( -> 
    equal $('.switch-element-2').hasClass('current'), true,   "Switch element 2 should have current class"
    Helper.trigger_key_event(13)
    setTimeout(( -> 
      equal $('.switch-element-2').hasClass('current'), true,  "Switch element 2 should have current class"
      equal /#switch-element-2/.test(document.URL), true, "URL should contain #switch-element-2"        
      start())
      , 20)
    )
    , 225)
  return

QUnit.test 'It should move to the second element and stay there, then trigger action on keypress, then move to next on keypress', 5, ->
  stop()
  $('.switch-element-2').attr("data-sw-single-stay", true)
  setTimeout(( -> 
    equal $('.switch-element-2').hasClass('current'), true,  "Switch element 2 should have current class"
    )
    , 125)
  setTimeout(( -> 
    equal $('.switch-element-2').hasClass('current'), true,   "Switch element 2 should have current class"
    Helper.trigger_key_event(13)
    setTimeout(( -> 
      equal $('.switch-element-2').hasClass('current'), true,  "Switch element 2 should have current class"
      equal /#switch-element-2/.test(document.URL), true, "URL should contain #switch-element-2"        
      setTimeout(( -> 
        Helper.trigger_key_event(13)
        equal $('.switch-element-3').hasClass('current'), true,  "Switch element 3 should have current class"
        start())
        , 200)
      )
      , 20)
    )
    , 225)
  return
