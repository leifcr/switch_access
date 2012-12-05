// Generated by CoffeeScript 1.4.0
(function() {
  var create_switch_element, create_switch_elements, create_switch_group, create_switch_group_with_elements, create_switch_groups_with_elements, trigger_key_event;

  create_switch_elements = function(count, startnum) {
    var elements, i;
    elements = [];
    i = startnum;
    while (i <= (startnum + count)) {
      elements.push(create_switch_element(i));
      i++;
    }
    return elements;
  };

  create_switch_group_with_elements = function(element_count, element_startnum, groupnum) {
    var group;
    group = create_switch_group(groupnum);
    group.append(create_switch_elements(element_startnum, element_count));
    return group;
  };

  create_switch_groups_with_elements = function(group_count, startnum, element_count, element_start_number, start_at_zero_for_elements) {
    var current_switch_element_startnum, groups, i;
    groups = [];
    i = startnum;
    current_switch_element_startnum = element_startnum;
    while (i <= (startnum + group_count)) {
      groups.push(create_switch_group_with_elements(element_count, current_switch_element_startnum, i));
      if (start_at_zero_for_elements !== true) {
        current_switch_element_startnum += element_count;
      }
      i++;
    }
    return [groups, current_switch_element_startnum];
  };

  create_switch_element = function(number) {
    var ret;
    ret = $("<div />");
    ret.addClass("switch-element-" + number).addClass("test-element").text("Switch Element " + number);
    return ret;
  };

  create_switch_group = function(number) {
    var ret;
    ret = $("<div />");
    ret.addClass("switch-element-" + number).addClass("test-group").text("Switch Group " + number);
    return ret;
  };

  trigger_key_event = function(key_code) {
    var event;
    event = $.Event("keypress");
    event.keyCode = key_code;
    return $(document).trigger(event);
  };

  QUnit.module('Two Switches, single elements', {
    setup: function() {
      var elements;
      elements = create_switch_elements(3, 1);
      console.log(elements);
      $('#qunit-fixture').prepend(elements);
      new SwitchAccess({
        debug: false,
        number_of_switches: 2
      });
    },
    teardown: function() {}
  });

  QUnit.test('It should start at the first element', 1, function() {
    equal($('.switch-element-1').hasClass('current'), true);
  });

}).call(this);