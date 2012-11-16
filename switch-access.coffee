###
 Switch Access for webpages
 (c) 2012 Leif Ringstad
 Licensed under the freeBSD license (see license.txt)
 Source: http://github.com/leifcr/switch-access
 v 1.0.1
###

class SwitchAccess
  constructor: (options) ->
    if (window['__switch_access_sci'] != undefined)
      window.__switch_access_sci.setoptions(options)
      return window.__switch_access_sci

    window.__switch_access_sci = this

    @options = 
      number_of_switches: 0
      keys_1: [32, 13] # Space / Enter
      keys_2: [[32], [13]] # Space / Enter
      element_class: "switch-element"
      highlight_element_id: "switch-highlight-element"
      highlight_element_activate_class: "switch-highlight-element-activate"
      hide_show_delay: 500
      move_fade_delay: 200
      pulsate: false
      sort_element_list_after_numbers: true
      debug: false
      margin_to_element: 5
      fields_where_keys_should_be_accepted: ["search"]
      use_highlight_div: true
      highlight_element_class: "switch-highlight"
      activate_element_class: "switch-highlight-activate"
      single_switch_move_time: 1500
      delay_before_activating_element: 0
      activate_first_link: true
      delay_for_allowed_keypress: 250;
      single_switch_restart_on_activate: true
      highlight_on_activate_time: 1000
      ensure_visible_element: true
      scroll_offset: 15
      animate_scroll_time: 200
      easing: "linear"

    @runtime = 
      active: false
      current_element: null
      current_element_idx: 0
      next_element_idx: 0
      element_list: null
      highlightdiv: null
      single_switch_timer_id: null
      action_triggered: false
      keypress_allowed: true
      element_to_click: null

    jQuery.extend @options, options
    @init();
  
  init: ->
    if (@options.debug)
      @logger = log4javascript.getLogger()
      appender = new log4javascript.InPageAppender("logger")
      appender.setWidth("100%")
      appender.setHeight("100%")
      appender.setThreshold(log4javascript.Level.ALL)
      @logger.addAppender(appender)

    @log("init")

    @readOptionsFromCookies();
    @buildElementList();
    @start();

  setoptions: (options) ->
    @log "setoptions"
    @log options
    @stop()
    jQuery.extend @options, options
    @start()

  log: (msg, raw = false) ->
    #console.log msg if @options.nested_debug
    if (@options.debug)
      if (raw)
        @logger.debug msg 
      else
        @logger.debug "SwitchAccess: " + msg 

  readOptionsFromCookies: ->
    if (jQuery.isFunction($.cookie))
      @log "read options from cookies"
      # read cookie to see if there are settings stored
      if ($.cookie('number_of_switches') != null)
        @options.number_of_switches = $.cookie('number_of_switches')
      if ($.cookie('keys_1') != null)
        @options.keys_1 = $.cookie('keys_1')
      if ($.cookie('keys_2') != null)
        @options.keys_2 = $.cookie('keys_2')
      if ($.cookie('single_switch_move_time') != null)
        @options.single_switch_move_time = $.cookie('single_switch_move_time')    

  buildElementList: ->
    if (@options.sort_element_list_after_numbers == true)
      temp_list = $("[class*=#{@options.element_class}-]")
      # warn if there are any elements that don't have any numbers
      if $(".#{@options.element_class}").length > 0
        msg = "Warning! Elements without numbers found and sort_element_list_after_numbers is set to true."
        console.log "SwitchAccess: #{msg}"
        @log msg
    else
      temp_list = $(".#{@options.element_class}")

    @log "buildElementList: count:#{temp_list.length}, class-name: #{@options.element_class}"

    if (@options.sort_element_list_after_numbers == true)
      @log "sorting list"
      search_regexp_class = ///#{@options.element_class}-\d+///
      search_regexp_num = ///\d+///
      temp_list.sort (a,b) ->
        item_class_name_a = search_regexp_class.exec($(a).attr("class"))
        item_class_name_b = search_regexp_class.exec($(b).attr("class"))
        num_a = 0
        num_b = 0
        if (item_class_name_a != null && item_class_name_b != null)
          num_a = search_regexp_num.exec(item_class_name_a)
          num_b = search_regexp_num.exec(item_class_name_b)
        window.__switch_access_sci.log "Sort: #{num_a} #{num_b}"
        num_a - num_b

    @runtime.element_list = temp_list

  deinit: ->
    @log "deinit"
    @stop()
    @removeHighlightdiv()

  start: ->
    return if (@options.number_of_switches == 0)
    @addHighlightdiv()
    @log "start"
    # highlight first element
    @registerCallbacks()
    @showHighlightdiv()
    @runtime.next_element_idx = 0
    @moveToNextElement()
    @startSingleSwitchTimer() if (@options.number_of_switches == 1)
    @runtime.action_triggered = false

  stop: ->
    @log "stop"
    # hide highlight div
    @hideHighlightdiv()
    @stopSingleSwitchTimer()

  moveToNextElement: ->
    if (@runtime.element_list.length < (@runtime.next_element_idx + 1))
      @runtime.next_element_idx = 0

    @log "moveToNextElement IDX: #{@runtime.next_element_idx}"
    if @runtime.current_element != null 
      @runtime.current_element.removeClass(@options.activate_element_class)
      @runtime.current_element.removeClass(@options.highlight_element_class)

    @runtime.current_element_idx = @runtime.next_element_idx
    @runtime.action_triggered = true
    @runtime.current_element = $(@runtime.element_list[@runtime.current_element_idx])
    @runtime.current_element.addClass(@options.highlight_element_class)
    @highLightElement($(@runtime.element_list[@runtime.current_element_idx]))
    @makeElementVisible($(@runtime.element_list[@runtime.current_element_idx]))
    @runtime.next_element_idx++
    @runtime.current_element.trigger("switch-access-move", [@runtime.current_element, @runtime.current_element_idx + 1])
    return 1

  highLightElement: (element) ->
    return unless @options.use_highlight_div
    @log "highLightElement IDX: #{@runtime.current_element_idx} Tag: #{element.get(0).tagName.toLowerCase()} classes: #{element.attr("class")}"
    coords = []
    size = []

    size["width"]  = element.outerWidth(false)  + (@options.margin_to_element * 2)
    size["height"] = element.outerHeight(false) + (@options.margin_to_element * 2)
   
    coords["left"] = element.offset().left - @options.margin_to_element - ((@runtime.highlightdiv.outerWidth() - @runtime.highlightdiv.innerWidth())/2)
    coords["top"]  = element.offset().top - @options.margin_to_element - ((@runtime.highlightdiv.outerWidth() - @runtime.highlightdiv.innerWidth())/2)

    @runtime.highlightdiv.width(size["width"])
    @runtime.highlightdiv.height(size["height"])

    @runtime.highlightdiv.offset({top: coords["top"], left: coords["left"]})
    @runtime.highlightdiv.fadeIn(@options.move_fade_delay)
    @runtime.highlightdiv.show(@options.move_fade_delay)
    # @log "Move to position Top: #{coords["top"]} Left: #{coords["left"]}"
    # @log "Element data:"
    # @log "Widths:  Outer-margin:#{element.outerWidth(true)} Outer:#{element.outerWidth()} Inner: #{element.innerWidth()} Actual: #{element.width()}"
    # @log "Heights: Outer-margin:#{element.outerHeight(true)} Outer:#{element.outerHeight()} Inner: #{element.innerHeight()} Actual: #{element.height()}"
    # @log "Pos: Left: #{element.offset().left} Top: #{element.offset().top}"
    # @log "highlightdiv data:"
    # @log "Widths:  Outer:#{@runtime.highlightdiv.outerWidth(true)} Inner: #{@runtime.highlightdiv.innerWidth()} Actual: #{@runtime.highlightdiv.width()}"
    # @log "Heights: Outer:#{@runtime.highlightdiv.outerHeight(true)} Inner: #{@runtime.highlightdiv.innerHeight()} Actual: #{@runtime.highlightdiv.height()}"
    # @log "Pos: Left: #{@runtime.highlightdiv.offset().left} Top: #{@runtime.highlightdiv.offset().top}"
 
  makeElementVisible: (element) ->
    return unless @options.ensure_visible_element == true
    @log "makeElementVisible"
    scrollval = null
    scroll_top = $(document).scrollTop()
    # positive scroll:
    if ($(window).height() + scroll_top) < (element.offset().top + element.outerHeight() + @options.scroll_offset)
      diff_to_make_visible = (element.offset().top + element.outerHeight() + @options.scroll_offset) - ($(document).scrollTop() + $(window).height())
      if (diff_to_make_visible > 0)
        scrollval = diff_to_make_visible + scroll_top
    # negative scroll:
    else if (scroll_top > (element.offset().top - @options.scroll_offset))
      if (element.offset().top - @options.scroll_offset < 0)
        scrollval = 0
      else
        scrollval = element.offset().top - @options.scroll_offset

    if (scroll_top != scrollval) && scrollval != null
      if (@options.animate_scroll_time == 0)
        $("html body").scrollTop(scrollval)
      else
        $("html body").animate({scrollTop: scrollval}, @options.animate_scroll_time, @options.easing);


  activateElement: ->
    @log "activateElement"
    @runtime.action_triggered = true
    if ((@runtime.current_element.is("a")) || (@activate_first_link == false))
      element_to_click = @runtime.current_element
    else
      # if element isn't a link, find first link within element and go to the url/trigger it
      element_to_click = @runtime.current_element.find("a")

    @log "Clicked Element: IDX: #{@runtime.current_element_idx} Element Tag: #{$(element_to_click).get(0).tagName.toLowerCase()} Text: #{$(element_to_click).text()}"
    if (element_to_click.length > 0)
      if (@options.delay_before_activating_element == 0)
        @runtime.current_element.trigger("switch-access-activate", [@runtime.current_element, @runtime.current_element_idx, element_to_click])
        element_to_click[0].click()
        # if (ret == true) && element_to_click.is("a")
        #   document.location = element_to_click.attr("href")

        if (@options.number_of_switches == 1)
          @runtime.next_element_idx = 0 if (@options.single_switch_restart_on_activate)
          @stopSingleSwitchTimer()
          @startSingleSwitchTimer()
        window.setTimeout(window.__switch_access_sci.removeHighlightCallback, @options.highlight_on_activate_time)
      else
        @runtime.element_to_click = element_to_click
        window.setTimeout(window.__switch_access_sci.activateElementCallBack, @options.delay_before_activating_element)

      @runtime.current_element.addClass(@options.activate_element_class)
      @runtime.highlightdiv.addClass(@options.highlight_element_activate_class) if @options.use_highlight_div
      return 2
    else
      @log "Nothing to activate/click... Missing a link within the element or should activate_first_link be true?"
  
    return 0      

  activateElementCallBack: ->
    window.__switch_access_sci.log "activateElementCallBack"
    element_to_click = window.__switch_access_sci.runtime.element_to_click
    window.__switch_access_sci.runtime.current_element.trigger("switch-access-activate", [window.__switch_access_sci.runtime.runtime.current_element, window.__switch_access_sci.runtime.runtime.current_element_idx, element_to_click])
    element_to_click[0].click() #trigger("click")
    # if (ret == true) && element_to_click.is("a")
    #   document.location = element_to_click.attr("href")

    if (window.__switch_access_sci.options.number_of_switches == 1)
      window.__switch_access_sci.runtime.next_element_idx = 0 if (window.__switch_access_sci.options.single_switch_restart_on_activate)
      window.__switch_access_sci.stopSingleSwitchTimer()
      window.__switch_access_sci.startSingleSwitchTimer()
    timeout(window.__switch_access_sci.removeHighlightCallback, window.__switch_access_sci.options.highlight_on_activate_time)


  singleSwitchTimerCallback: ->
    window.__switch_access_sci.log "singleSwitchTimerCallback"
    window.__switch_access_sci.moveToNextElement();

  allowKeyPressCallback: ->
    window.__switch_access_sci.log "allowKeyPressCallback"
    window.__switch_access_sci.runtime.keypress_allowed = true

  removeHighlightCallback: ->
    window.__switch_access_sci.log "removeHighlightCallback"
    window.__switch_access_sci.runtime.highlightdiv.removeClass(window.__switch_access_sci.options.highlight_element_activate_class) if window.__switch_access_sci.options.use_highlight_div
    window.__switch_access_sci.runtime.current_element.removeClass(window.__switch_access_sci.options.activate_element_class)    

  addHighlightdiv: ->
    return unless @options.use_highlight_div
    return if $("div##{@options.highlight_element_id}").length > 0
    @log "addHighlightdiv"
    highlightdiv = $("<div id=\"#{@options.highlight_element_id}\" class=\"#{@options.highlight_element_id}\">&nbsp;</div>")
    highlightdiv.css('position','absolute')
    $('body').append(highlightdiv)
    @runtime.highlightdiv = $("div##{@options.highlight_element_id}")

  removeHighlightdiv: ->
    return unless @options.use_highlight_div
    @log "removeHighlightdiv"
    @runtime.highlightdiv.remove()

  showHighlightdiv: ->
    return unless @options.use_highlight_div
    @log "showHighlightdiv"
    @runtime.highlightdiv.fadeIn(@options.hide_show_delay)
  
  hideHighlightdiv: ->
    return unless @options.use_highlight_div
    @log "hideHighlightdiv"
    @runtime.highlightdiv.fadeOut(@options.hide_show_delay)

  callbackForKeyPress: (event) ->
    @log "callbackForKeyPress keycode: #{event.which} Allowed: #{@runtime.keypress_allowed}"
    return if (@options.number_of_switches == 0)
    action = 0

    if @options.number_of_switches == 1
      if event.which in @options.keys_1
        if !@runtime.keypress_allowed
          event.stopPropagation();
          return false
        action = @activateElement() 

    else if @options.number_of_switches == 2
      if (event.which in @options.keys_2[0]) || (event.which in @options.keys_2[1])
        if !@runtime.keypress_allowed
          event.stopPropagation();
          return false
      action = @moveToNextElement() if event.which in @options.keys_2[0]
      action = @activateElement() if event.which in @options.keys_2[1]

    if (@runtime.action_triggered)
      @runtime.action_triggered = false
      @runtime.keypress_allowed = false
      timeout = @options.delay_for_allowed_keypress
      if (action == 2)
        if (@options.number_of_switches == 1)
          if (@options.single_switch_move_time > @options.delay_before_activating_element)
            timeout = @options.single_switch_move_time
          else
            timeout = @options.delay_before_activating_element
        else
          if (@options.delay_before_activating_element > timeout)
            timeout = @options.delay_before_activating_element

      window.setTimeout(window.__switch_access_sci.allowKeyPressCallback, timeout)
      event.stopPropagation();
      return false;
    else
      return true;

  startSingleSwitchTimer: ->
    @log "startSingleSwitchTimer"
    @runtime.single_switch_timer_id = window.setInterval(window.__switch_access_sci.singleSwitchTimerCallback, @options.single_switch_move_time)

  stopSingleSwitchTimer: ->
    @log "stopSingleSwitchTimer"
    window.clearInterval(@runtime.single_switch_timer_id)

  registerCallbacks: ->
    @log "registerCallbacks"
    # $(document).on("keypress", @callbackForKeyPress)
    $(document).on("keypress", (event) -> 
      window.__switch_access_sci.callbackForKeyPress(event))

window.SwitchAccess = SwitchAccess
