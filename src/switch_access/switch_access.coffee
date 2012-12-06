###
Switch Access for webpages
(c) 2012 Leif Ringstad
Dual-licensed under GPL or commercial license (LICENSE and LICENSE.GPL)
Source: http://github.com/leifcr/switch_access
v 1.1.1
###

SwitchAccessCommon =
  generateRandomUUID: ->
    "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = (if c is "x" then r else (r & 0x3 | 0x8))
      v.toString 16
  options:
    ###
    Element highlighting
    ###
    highlighter:
      use:                      true
      content:                  ""
      class:                    "highlighter"
      current_class:            "current"
      activate_class:           "activate"
      margin_to_element:        5
      selector_for_set_to_size: ".highlighter"
      watch_for_resize:         true
      use_size_position_check:  true
      holder_id:               "sw-highlighter-holder"

    highlight:
      element:
        current_class:          "current"
        activate_class:         "activate"

      activate_time:            1000

    debug: false

    ###
    Internal options, but can be changed if needed
    ###
    internal:                
      unique_element_data_attribute: "sw-elem"
      set_unique_element_class:      false

  # Actions (Enumish)
  actions:
    none:                     0
    moved_to_next_element:    1
    moved_to_next_level:      2
    moved_to_previous_level:  3
    triggered_action:         10
    triggered_delayed_action: 11
    stayed_at_element:        20



class SwitchAccess
  constructor: (options) ->
    # return existing instance if already initialized, as there should only be one instance of Switch Access on a page
    if typeof (window['__switch_access_sci']) != "undefined" && window['__switch_access_sci'] != null
      window.__switch_access_sci.setoptions(options)
      return window.__switch_access_sci

    window.__switch_access_sci = this
    ###
    Options
    ###
    @options = 
      ###
        Switch/Key settings 
      ###
      switches:
        number_of_switches:                  0
        keys_1:                              [32, 13] # Space / Enter
        keys_2:                              [[9, 32], [13]] # Space / Enter
        #keys_3:                             # forward/backward and select
        single_switch_move_time:             1500
        single_switch_restart_on_activate:   true
        delay_before_activating_element:     0
        delay_for_allowed_keypress:          250;
        groups:                              true;

      ###
      classes for elements/groups
      ###
      dom:
        element_class:            "switch-element-" # Use classnames such as switch-element-1 switch-element-2 or change this value
        # sort_elements_after_numbers:  true              # By setting this to false, you can use the classname above without numbers, but the switch-order cannot be specified
        start_element:            "body"

      ###
      Other settings
      ###
      # Use .search where you have class="search" or #search for id="search" (jQuery selectors)
      key_filter_skip:        [".search"]
      activate_first_link:    true # activate element or first link within
      debug:                  false

      ###
      Visual
      ###
      visual:
        hide_show_delay:        500
        move_fade_delay:        200
        pulsate:                false
        ensure_visible_element: true # ensure element is visible on the page
        scroll_offset:          15 # offset from top/bottom in pixels for the element
        animate_scroll_time:    200 # time to use for animating scroll
        easing:                 "linear" # easing to use for scrolling

    ###
    Runtime properties
    ###
    @runtime = 
      active:             false
      element_list:       null # an array hashes with element + children
      current_list:       null # the current list (Root or a elements list of children)
      parent_list:        null # the list the parent is in when moving into a child
      # next_element:                 null # next_element_list ?
      element:
        current:          null  # the current element within the active group
        idx:              0     # the current element idx within the active group
        level:            0     # the current level within a group or nested group
        next_level:       0     # next level when moving to elements.
        next_idx:         0     # next elements idx
        parent_idx:       0     # the last idx on the parent before moving into the children of an element
      action_triggered:   false
      keypress_allowed:   true
      element_to_click:   null
      timers:
        single_switch_id: null

      highlighter_holder: null
    
    @setoptions(options);
    @init();
  
  init: ->
    if (@options.debug)
      appender = null
      @logger = log4javascript.getLogger()
      if $('#logger').length > 0
        if $('#logger').find('iframe').length <= 0
          appender = new log4javascript.InPageAppender("logger")
          appender.setWidth("100%")
          appender.setHeight("100%")
          appender.setThreshold(log4javascript.Level.ALL)
          @logger.setLevel(log4javascript.Level.ALL)
          @logger.addAppender(appender)

    @log("init")
    @createHighlighterHolder() if SwitchAccessCommon.options.highlighter.use
    @registerCallbacks()
    @start();

  setoptions: (options) ->
    @log "setoptions"
    # @log options, "trace", true
    @stop() if @runtime.active == true
    jQuery.extend SwitchAccessCommon.options, {
      highlighter: options.highlighter, 
      highlight:   options.highlight, 
      internal:    options.internal,
      debug:       options.debug
    }
    delete options.highlighter
    delete options.highlight
    delete options.internal
    jQuery.extend true, @options, options
    return

  log: (msg, type = "debug", raw = false) ->
    #console.log msg if @options.nested_debug
    if (@options.debug)
      if (raw)
        @logger[type] msg 
      else
        @logger[type] "SwitchAccess: " + msg 

  checkForNonNumberedElements: ->
    if $(".#{@options.dom.element_class}").length > 0
      msg = "Warning! #{$(".#{@options.dom.element_class}").length} element(s) without numbers found. Class selector is: #{@options.element_class}."
      console.log "SwitchAccess: " + msg # This needs to be shown on the console, as it affects the functionality
      @log msg, "warning"

  buildListFromjqElement: (jq_element, parent, depth = 0) ->
    not_str = "[class*=#{@options.dom.element_class}] [class*=#{@options.dom.element_class}]"
    i = 0
    while i < depth
      not_str += " [class*=#{@options.dom.element_class}]"
      i++

    temp_list = jq_element.find("[class*=#{@options.dom.element_class}]").not(not_str)
    @log "buildListFromjqElement - element count #{temp_list.length} depth: #{depth} element-classes:#{jq_element.attr("class")}", "trace"
    return [] if temp_list.length <= 0
    # warn if there are any elements that don't have any numbers
    @hashAlizeAndRecurseList(@sortList(temp_list, @options.dom.element_class), parent, depth)

  hashAlizeAndRecurseList: (list, parent, depth) ->
    ret = []
    i = 0
    while i < list.length
      new_element = new SwitchAccessElement($(list[i]), @runtime.highlighter_holder, @, parent)
      new_element.children(@buildListFromjqElement($(list[i]), new_element, depth + 1 ))
      ret.push( new_element )
      i++
    ret

  sortList: (list, list_class) ->
    @log "sortList Sorting list for #{list_class} Elements: #{list.length}"
    search_regexp_class = ///#{list_class}\d+///
    search_regexp_num = ///\d+///
    list.sort (a,b) =>
      item_class_name_a = search_regexp_class.exec($(a).attr("class"))
      item_class_name_b = search_regexp_class.exec($(b).attr("class"))
      num_a = 0
      num_b = 0
      if (item_class_name_a != null && item_class_name_b != null)
        num_a = search_regexp_num.exec(item_class_name_a)
        num_b = search_regexp_num.exec(item_class_name_b)
      # @log "Sort: #{num_a} #{num_b}", "trace"
      num_a - num_b
    list

  buildElementList: ->
    @runtime.element_list = @buildListFromjqElement($(@options.dom.start_element), null, 0)
    @log "buildElementList: count:#{@runtime.element_list.length}, class-name: #{@options.dom.element_class}"
    return

  deinit: ->
    @log "deinit"
    @stop()
    @removeHighlightdiv()

  start: ->
    return if (@options.switches.number_of_switches == 0) || (@runtime.active == true)
    @log "start"
    @buildElementList()
    # return
    @runtime.active = true
    @moveToFirstRootElement()
    @startSingleSwitchTimer()
    @runtime.action_triggered = false

  stop: ->
    return if (@runtime.active == false)
    @log "stop"
    @runtime.active = false
    @removeHighlight()
    @removeActivateClass()
    @stopSingleSwitchTimer()

  destroy: ->
    @log "destroy"
    @stop()
    @removeCallbacks()
    @destroy_elements(@runtime.element_list)
    @removeHighlighterHolder()
    @runtime.element_list       = null
    @runtime.current_list       = null
    @runtime.parent_list        = null
    @runtime.element.current    = null
    @runtime.highlighter_holder = null
    window.__switch_access_sci  = null

  destroy_elements: (list) ->
    @log "destroy_elements", "trace"
    i = 0
    while i < list.length
      if (list[i].length > 1)
        @destroy_elements(list[i]) 
      else
        @destroy_element(list[i])
      i++
    return

  destroy_element: (element) ->
    @log "destroy_element #{element.uniqueDataAttr()}", "trace"
    element.destroy()
    return

  moveToFirstRootElement: ->
    @runtime.element.idx = -1
    @moveToNextElementAtLevel()

  moveToNextElementAtLevel: ->
    @log "moveToNextElementAtLevel", "trace"
    @runtime.element.next_idx = @runtime.element.idx + 1
    # verify that next idx is possible for "root"
    if @runtime.element.next_level == @runtime.element.level and @runtime.element.level == 0
      if (@runtime.element.next_idx >= @runtime.element_list.length)
        @runtime.element.next_idx = 0

    # see if we should move "out" of the current group
    if @runtime.element.next_level isnt 0
      if @runtime.element.next_idx >= @runtime.current_list.length
        return @moveToPreviousLevel()

    if @moveToNext()
      @runtime.element.current.jq_element().trigger("switch-access-move", [@runtime.element.idx, @runtime.element.level, @runtime.element.current])
      return SwitchAccessCommon.actions.moved_to_next_element
    else
      return SwitchAccessCommon.actions.stayed_at_element

  moveToNextLevel: ->
    @log "moveToNextLevel", "trace"
    # "catch" if the current element doesn't have children
    if @runtime.element.current.children().length > 1
      @runtime.element.next_level = @runtime.element.level + 1
      @runtime.element.next_idx   = 0
      # return SwitchAccessCommon.actions.stayed_at_element

    if @moveToNext()
      @runtime.element.current.jq_element().trigger("switch-access-enter-group", [@runtime.element.idx, @runtime.element.level, @runtime.element.current])
      return SwitchAccessCommon.actions.moved_to_next_level
    else
      return SwitchAccessCommon.actions.stayed_at_element

  moveToPreviousLevel: ->
    @log "moveToPreviousLevel", "trace"
    @runtime.element.next_level = @runtime.element.level - 1
    @runtime.element.next_idx = @runtime.element.parent_idx
    # safety catch impossible levelss
    if @runtime.element.next_level < 0
      @runtime.element.next_level = 0 
      @runtime.element.next_idx = 0
    
    if @moveToNext()
      @runtime.element.current.jq_element().trigger("switch-access-leave-group", [@runtime.element.idx, @runtime.element.level, @runtime.element.current])
      return SwitchAccessCommon.actions.moved_to_previous_level
    else
      return SwitchAccessCommon.actions.stayed_at_element

  moveToNext: ->
    @log "moveToNext Current: I: #{@runtime.element.next_idx} L: #{@runtime.element.level} Next: I: #{@runtime.element.next_idx} L: #{@runtime.element.next_level}"
    @runtime.action_triggered = true

    # return if current level and idxs are equal
    return false if (@runtime.element.next_level == @runtime.element.level) and (@runtime.element.idx == @runtime.element.next_idx)

    @removeHighlight()

    # find list to work on element    
    if @runtime.element.next_level > @runtime.element.level
      list_n = @runtime.element.current.children()
      @runtime.element.parent_idx = @runtime.element.idx
      @runtime.parent_list = @runtime.current_list
      @runtime.element.next_idx = 0
    else if @runtime.element.next_level < @runtime.element.level
      @runtime.element.next_idx = @runtime.element.parent_idx
      if @runtime.element.current.parent() isnt null
        list_n = @runtime.parent_list
      else
        list_n = @runtime.element_list
    else if @runtime.element.next_level == 0
      list_n = @runtime.element_list
    else
      list_n = @runtime.current_list

    # if the element has children, it's most likely that the children should be highlighted
    if list_n[@runtime.element.next_idx].children().length > 0
      child.highlight() for child in list_n[@runtime.element.next_idx].children()
    else
      # if the next element doesn't have any children, highlight it
      list_n[@runtime.element.next_idx].highlight()

    @runtime.element.idx     = @runtime.element.next_idx
    @runtime.element.level   = @runtime.element.next_level
    @runtime.current_list    = list_n
    @runtime.element.current = list_n[@runtime.element.idx]

    @makeElementVisible()
    return true

  removeHighlight: ->
    @log "removeHighlight"
    return if @runtime.current_list is null
    if @runtime.element.current.children().length == 0
      @runtime.element.current.removeHighlight()
    else
    # else it's most likely that the children should be highlighted
      child.removeHighlight() for child in @runtime.element.current.children()
    return

  removeActivateClass: ->
    @log "removeHighlight"
    return if @runtime.current_list is null
    if @runtime.element.current.children().length == 0
      @runtime.element.current.removeActivateClass()
    else
    # else it's most likely that the children should be highlighted
      child.removeActivateClass() for child in @runtime.element.current.children()
    return

  ###
  Make the element(s) visible. If the current selected element is a group, they are all moved inside the visible area of the screen
  ### 
  makeElementVisible: ->
    return unless @options.visual.ensure_visible_element == true
    @log "makeElementVisible"
    scrollval = null
    scroll_top = $(document).scrollTop()
    element = @runtime.element.current.jq_element()
    # positive scroll:
    if ($(window).height() + scroll_top) < (element.offset().top + element.outerHeight() + @options.visual.scroll_offset)
      diff_to_make_visible = (element.offset().top + element.outerHeight() + @options.visual.scroll_offset) - ($(document).scrollTop() + $(window).height())
      if (diff_to_make_visible > 0)
        scrollval = diff_to_make_visible + scroll_top
    # negative scroll:
    else if (scroll_top > (element.offset().top - @options.visual.scroll_offset))
      if (element.offset().top - @options.visual.scroll_offset < 0)
        scrollval = 0
      else
        scrollval = element.offset().top - @options.visual.scroll_offset

    if (scroll_top != scrollval) && scrollval != null
      if (@options.visual.animate_scroll_time == 0)
        # for FF
        $("html").scrollTop(scrollval)
        # for Chrome
        $("html body").scrollTop(scrollval)
      else
        # for FF
        $("html").animate({scrollTop: scrollval}, @options.visual.animate_scroll_time, @options.visual.easing);
        # for Chrome
        $("html body").animate({scrollTop: scrollval}, @options.visual.animate_scroll_time, @options.visual.easing);


  activateElement: ->
    @log "activateElement"
    @runtime.action_triggered = true
    @stopSingleSwitchTimer()

    @log "Activate Element: idx: #{@runtime.element.idx} level: IDX: #{@runtime.element.level} uuid: #{@runtime.element.current.uniqueDataAttr()}"
    if (@options.switches.delay_before_activating_element == 0)
      return @activateElementCallBack()
      # window.setTimeout(( -> @removeHighlightCallback;return), @options.highlight_on_activate_time)
    else
      @runtime.element.current.jq_element().addClass(@options.element_activate_class)
      if @runtime.element.current.children().length > 0
        child.addActivateClass() for child in @runtime.element.current.children()
      else
        @runtime.element.current.addActivateClass()

      window.setTimeout(( => @removeActivateClass(); @activateElementCallBack(); return), @options.switches.delay_before_activating_element)
      return SwitchAccessCommon.actions.triggered_delayed_action

  activateElementCallBack: ->
    @log "activateElementCallBack"

    # see if the element has children, if so go into level
    if @runtime.element.current.children().length > 0
      @startSingleSwitchTimer()
      return @moveToNextLevel()
    # else the element should "activate"

    if ((@runtime.element.current.jq_element().is("a")) || (@activate_first_link == false))
      element_to_click = @runtime.element.current.jq_element()
    else
      # if element isn't a link, find first link within element and go to the url/trigger it
      element_to_click = @runtime.element.current.jq_element().find("a")

    @log "Triggering Element: IDX: #{@runtime.element.current_idx} Element Tag: #{$(element_to_click).get(0).tagName.toLowerCase()} Text: #{$(element_to_click).text()}"

    @runtime.element.current.jq_element().trigger("switch-access-activate", [@runtime.element.idx, @runtime.element.level, element_to_click, @runtime.element.current])
    if element_to_click.length > 0
      element_to_click[0].click() #trigger("click")
      # if (ret == true) && element_to_click.is("a")
      #   document.location = element_to_click.attr("href")
      if (@options.switches.number_of_switches == 1)
        @runtime.next_element_idx = -1 if (@options.single_switch_restart_on_activate)
        @runtime.next_level       = 0
        @startSingleSwitchTimer()
      # window.setTimeout(( -> @removeHighlightCallback; return), @options.highlight_on_activate_time)
    else
      msg = "Nothing to do. Verify your settings and"
      @log msg, "warn"
      console.log "SwitchAccess: Warning: " + msg
      return SwitchAccessCommon.actions.none

    return SwitchAccessCommon.actions.triggered_action


  singleSwitchTimerCallback: ->
    @log "singleSwitchTimerCallback"
    @moveToNextElementAtLevel();

  allowKeyPressCallback: ->
    @log "allowKeyPressCallback"
    @runtime.keypress_allowed = true

  createHighlighterHolder: ->
    if $("div##{SwitchAccessCommon.options.holder_id}").length == 0
      @runtime.highlighter_holder = $("<div id=\"#{SwitchAccessCommon.options.highlighter.holder_id}\"></div>")
      $('body').append(@runtime.highlighter_holder)
    return

  removeHighlighterHolder: ->
    $("div##{SwitchAccessCommon.options.highlighter.holder_id}").remove()

  callbackForKeyPress: (event) ->
    @log "callbackForKeyPress keycode: #{event.which} Allowed: #{@runtime.keypress_allowed}"
    return if (@options.switches.number_of_switches == 0)
    action = 0

    if @options.switches.number_of_switches == 1
      if event.which in @options.switches.keys_1
        if !@runtime.keypress_allowed
          event.stopPropagation();
          return false
        action = @activateElement()

    else if @options.switches.number_of_switches == 2
      if (event.which in @options.switches.keys_2[0]) || (event.which in @options.switches.keys_2[1])
        if !@runtime.keypress_allowed
          event.stopPropagation();
          return false
      action = @moveToNextElementAtLevel() if event.which in @options.switches.keys_2[0]          
      action = @activateElement() if event.which in @options.switches.keys_2[1]

    if (@runtime.action_triggered)
      @runtime.action_triggered = false
      @runtime.keypress_allowed = false
      timeout = @options.switches.delay_for_allowed_keypress
      if (action == SwitchAccessCommon.actions.triggered_action) || (action == SwitchAccessCommon.actions.triggered_delayed_action)
        if (@options.switches.number_of_switches == 1)
          if (@options.switches.single_switch_move_time > @options.switches.delay_before_activating_element)
            timeout = @options.switches.single_switch_move_time
          else
            timeout = @options.switches.delay_before_activating_element
        else
          if (@options.switches.delay_before_activating_element > timeout)
            timeout = @options.switches.delay_before_activating_element

      if timeout == 0
        @allowKeyPressCallback()
      else
        window.setTimeout((=>@allowKeyPressCallback();return), timeout)

      event.stopPropagation();
      return false
    else
      return true

  startSingleSwitchTimer: ->
    return unless @options.switches.number_of_switches == 1
    @log "startSingleSwitchTimer", "trace"
    @runtime.single_switch_timer_id = window.setInterval(( => @singleSwitchTimerCallback();return), @options.switches.single_switch_move_time)

  stopSingleSwitchTimer: ->
    return unless @options.switches.number_of_switches == 1
    @log "stopSingleSwitchTimer", "trace"
    window.clearInterval(@runtime.single_switch_timer_id)

  removeCallbacks: ->
    @log "removeCallbacks", "trace"
    $(document).off("keypress.switch_access");

  registerCallbacks: ->
    @log "registerCallbacks", "trace"
    # $(document).on("keypress", @callbackForKeyPress)
    # $(document).on("keydown", (event) => 
    $(document).on("keypress.switch_access", (event) => 
      @callbackForKeyPress(event)
      false
      
    ) 
    true

window.SwitchAccess = SwitchAccess

class SwitchAccessElement
  constructor: (jq_element, highlight_holder = null, logger = null, parent = null, children = []) ->
    @options = 
      debug: false

    @runtime = 
      highligthed:      false
      jq_highlighter:   null
      jq_element:       jq_element
      uuid:             null
      watching:         false
      csswatch_init:    false
      parent:           parent
      children:         children
    @logger = logger

    if highlight_holder == null then @init($('body')) else @init(highlight_holder)
  
  init: (highlight_holder)->
    @options.debug = SwitchAccessCommon.options.debug
    @uniqueDataAttr(true)
    @createHighlighter(highlight_holder)
    @log "init", "trace"

  destroy: ->
    @log "destroy", "trace"
    @destroyHighlighter()
    parent = null
    children = null
    jq_element = null

  parent: (parent = null) ->
    if parent == null
      @runtime.parent
    else
      @runtime.parent = parent

  children: (children = null) ->
    if children == null
      @runtime.children
    else
      @runtime.children = children

  jq_element: (jq_element = null) ->
    if (jq_element == null)
      @runtime.jq_element
    else
      @runtime.jq_element = jq_element

  log: (msg, type = "debug", raw = false) ->
    #console.log msg if @options.nested_debug
    if @options.debug && @logger != null
      if (raw)
        @logger.log "Element: #{@runtime.uuid} :", type
        @logger.log msg, type, true
      else
        @logger.log "Element: #{@runtime.uuid} : #{msg}", type

  ###
  Trigger the active element, link or event depending on options
  ###
  trigger: ->
    @log "trigger"

  ###
  Show the highlighter and add highlight class to current object
  ###
  highlight: ->
    @log "highlight"
    @runtime.jq_element.addClass(SwitchAccessCommon.options.highlight.element.current_class)
    return unless SwitchAccessCommon.options.highlighter.use
    @runtime.jq_highlighter.addClass(SwitchAccessCommon.options.highlighter.current_class)
    @runtime.jq_highlighter.show()
    # Must show the element before moving, else the offset will not be correct
    @setHighlighterSizeAndPosition()
    if SwitchAccessCommon.options.highlighter.watch_for_resize
      if @runtime.watching == false
        @enableCSSWatch()

  ###
  Hide highlighter and remove highlight class on the current object(s)
  ###
  removeHighlight: ->
    @log "removeHighlight"
    @runtime.jq_element.removeClass(SwitchAccessCommon.options.highlight.element.current_class)
    @runtime.jq_element.removeClass(SwitchAccessCommon.options.highlight.element.activate_class)
    return unless SwitchAccessCommon.options.highlighter.use
    @runtime.jq_highlighter.removeClass(SwitchAccessCommon.options.highlighter.current_class)
    @runtime.jq_highlighter.removeClass(SwitchAccessCommon.options.highlighter.activate_class)
    @runtime.jq_highlighter.hide()
    if SwitchAccessCommon.options.highlighter.watch_for_resize
      @disableCSSWatch()

  addActivateClass: ->
    @runtime.jq_element.addClass(SwitchAccessCommon.options.highlight.element.activate_class)
    return unless SwitchAccessCommon.options.highlighter.use
    @runtime.jq_highlighter.addClass(SwitchAccessCommon.options.highlighter.activate_class)

  removeActivateClass: ->
    @log "removeActivateClass"
    @runtime.jq_element.removeClass(SwitchAccessCommon.options.highlight.element.activate_class)
    return unless SwitchAccessCommon.options.highlighter.use
    @runtime.jq_highlighter.removeClass(SwitchAccessCommon.options.highlighter.activate_class)

  ###
  Set Highlighter size and position
  ###
  setHighlighterSizeAndPosition: ->
    @setHighlighterSize(@runtime.jq_element, @runtime.jq_highlighter)
    @setHighlighterPosition(@runtime.jq_element, @runtime.jq_highlighter)

  ###
  Set highlighter position
  ###
  setHighlighterPosition: (element, highlighter) ->
    # posshift = SwitchAccessCommon.options.highlighter.margin_to_element #+ ((highlighter.outerWidth() - highlighter.innerWidth())/2)
    @log "m_to_el: #{SwitchAccessCommon.options.highlighter.margin_to_element}, outerW-innerW: #{highlighter.outerWidth() - highlighter.width()} outerH-innerH: #{highlighter.outerHeight() - highlighter.innerHeight()}", "trace"
    position = {
      top:  element.offset().top  - SwitchAccessCommon.options.highlighter.margin_to_element - (highlighter.outerHeight() - highlighter.innerHeight())/2
      left: element.offset().left - SwitchAccessCommon.options.highlighter.margin_to_element - (highlighter.outerWidth()  - highlighter.innerWidth())/2
    }
    return if (highlighter.offset().top == position.top) and (highlighter.offset().left == position.left)
    highlighter.offset(position)
    @log "setHighlighterPosition left: #{position.left} top: #{position.top}", "trace"
    return

  ###
  Set size on the Highlighter object to the match the given element
  ###
  setHighlighterSize: (element, highlighter) ->
    w  = element.outerWidth(false)  + (SwitchAccessCommon.options.highlighter.margin_to_element * 2)
    h  = element.outerHeight(false) + (SwitchAccessCommon.options.highlighter.margin_to_element * 2)
   
    highlighter.width(w)
    highlighter.height(h)
    @log "setHighlighterSize w: #{w}, h: #{h}", "trace"
    return

  ###
  Create the highlighter DOM object
  ###
  createHighlighter: (jq_holder)->
    return if (SwitchAccessCommon.options.highlighter.use is false) or (@runtime.jq_highlighter isnt null)
    @log "createHighlight"

    @runtime.jq_highlighter = $("<div id=\"sw-el-#{@runtime.uuid}\" class=\"#{SwitchAccessCommon.options.highlighter.class}\"></div>")
    jq_holder.append(@runtime.jq_highlighter)
    @runtime.jq_highlighter.css('position','absolute')
    @runtime.jq_highlighter.hide();
    @runtime.jq_highlighter.append(SwitchAccessCommon.options.highlighter.content)

    if SwitchAccessCommon.options.watch_for_resize
      # check if content contains selector to use for resizeing
      if @runtime.jq_highlighter.find(SwitchAccessCommon.options.highlighter.selector_for_set_to_size).length == 0
        @runtime.jq_highlighter.addClass(SwitchAccessCommon.options.highlighter.selector_for_set_to_size)
  
  ###
  Destroy the highlighter DOM object
  ###
  destroyHighlighter: ->
    return if @runtime.jq_highlighter == null
    @log "destroyHighlight", "trace"

    @runtime.jq_highlighter.remove()
    @runtime.jq_highlighter = null

  ###
  Enable wathcing CSS changes on the element belonging to this object  
  ###
  enableCSSWatch: ->
    return unless SwitchAccessCommon.options.highlighter.use == true && SwitchAccessCommon.options.highlighter.watch_for_resize 
    @log "enableCSSWatch", "trace"
    @runtime.watching = true
    if @runtime.csswatch_init
      @runtime.jq_element.csswatch('start')
    else
      @runtime.csswatch_init = true
      @runtime.jq_element.csswatch({
        props: "top,left,bottom,right,width,height"
        props_functions: {
          top:    "offset().top"
          left:   "offset().left"
          bottom: "offset().bottom"
          right:  "offset().right"
          outerwidth:  "outerWidth(false)"
          outerheight: "outerHeight(false)"
          }
        callback: (->@callbackForResize????)
        })

  ###
  Disable watching CSS changes on the element belonging to this object
  ###
  disableCSSWatch: ->
    return unless SwitchAccessCommon.options.highlighter.use == true && SwitchAccessCommon.options.highlighter.watch_for_resize
    @log "disableCSSWatch", "trace"
    @runtime.watching = false
    @runtime.jq_element.csswatch('stop')

  ###
  Add a data attribute to the element that has a unique ID.
  Will also add the same attribute as a class if option set_unique_element_class is enabled.
  ###
  uniqueDataAttr: (create = false) ->
    @log "uniqueDataAttr: Create: #{create}", "trace"
    if create
      @runtime.uuid = SwitchAccessCommon.generateRandomUUID()
      @runtime.jq_element.data(SwitchAccessCommon.options.internal.unique_element_data_attribute, @runtime.uuid)
      if SwitchAccessCommon.options.set_unique_element_class == true
        @runtime.jq_element.addClass("#{SwitchAccessCommon.options.internal.unique_element_data_attribute}+uuid")
      @runtime.uuid
    else
      @runtime.uuid

  ###
  Callback for resize event on this particular element
  ###
  callbackForResize: (event, changes) ->
    @log "callbackForResize", "trace"
    return unless SwitchAccessCommon.options.highlighter.use
    @setHighlighterSize(@runtime.jq_element, @runtime.jq_highlighter)
    @setHighlighterPosition(@runtime.jq_element, @runtime.jq_highlighter)
    # if (changes.keys)

# TODO: Fix instance object timeout:
# setTimeout(function(thisObj) { thisObj.methodToCall(); }, time, this)
# this is for ie/ff/chrome ?
# setTimeout( function() { return this.methodToCall.apply( this, arguments ); }, time );

