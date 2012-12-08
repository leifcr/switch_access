if typeof(window.Helper) == "undefined"
  window.Helper =
    create_switch_elements: (startnum, element_count, prepend_switch_href = "") ->
      elements = []
      i = startnum
      while i < (startnum + element_count)
        elements.push(Helper.create_switch_element(i, prepend_switch_href))
        i++
      elements

    create_switch_group_with_elements: (element_count, element_startnum, groupnum) ->
      group = Helper.create_switch_group(groupnum)
      group.append(Helper.create_switch_elements(element_startnum, element_count, "group-#{groupnum}-"))
      group

    create_switch_groups_with_elements: (group_count, startnum, element_count, element_start_number, start_at_zero_for_elements) ->
      groups = []
      i = startnum
      current_switch_element_startnum = element_start_number
      while i < (startnum + group_count)
        groups.push(Helper.create_switch_group_with_elements(element_count, current_switch_element_startnum, i))
        current_switch_element_startnum += element_count unless start_at_zero_for_elements == true
        i++ 
      groups

    create_switch_element: (number, prepend_switch_href = "") ->
      ret = $("<div />")
      ret.addClass("switch-element-#{number}").addClass("test-element")
      ret.append($("<a href=\"##{prepend_switch_href}switch-element-#{number}\"></a>").text("Switch Element #{number}"))
      ret

    create_switch_group: (number) ->
      ret = $("<div />")
      ret.addClass("switch-element-#{number}").addClass("test-group").text("Switch Group #{number}")
      ret

    trigger_key_event: (key_code) -> 
      # trigger event
      event = $.Event( "keydown" );
      event.which = key_code;
      $( document ).trigger( event );
