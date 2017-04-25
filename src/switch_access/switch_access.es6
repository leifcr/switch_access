/*
Switch Access for webpages
(c) 2012-2015 Leif Ringstad
Dual-licensed under GPL or commercial license (LICENSE and LICENSE.GPL)
Source: http://github.com/leifcr/switch_access
v 1.1.13
*/

let SwitchAccessCommon = {
  generateRandomUUID() {
    return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
      let r = (Math.random() * 16) | 0;
      let v = (c === "x" ? r : ((r & 0x3) | 0x8));
      return v.toString(16);
    });
  },
  options: {
    /*
    Element highlighting using the built in Highlighter object feature
    */
    highlighter: {
      /*
      Use highlighter div element for each element. A div is positioned absolute
      around the element and shown/hidden accordingly
      Default: true
      */
      use:                      true,

      /*
      Additional content for the highlighter
      Note: The content is placed within every highlighter and multiple
      highlighters can be visible at the same time. It is best to not
      use IDs on elements placed inside the highlighter, to avoid duplicate
      IDs on a page
      Default: ""
      */
      content:                  "",

      /*
      Class for the highlighter
      Default: "highlighter"
      */
      class:                    "highlighter",

      /*
      The class when a highlighter is active/currently selected
      Default: "current"
      */
      current_class:            "current",

      /*
      The class when a group is active/currently selected
      Default: "current"
      */
      group_current_class:      "current_group",

      /*
      The class when set on a highlighter when activated action is triggered
      Note: only usable if options.visual.delay_before_activating_element is > 0
      Default: "activate"
      */
      activate_class:           "activate",

      /*
      Margin between the highlighter and the element
      Default: 5
      */
      margin_to_element:        5,

      /*
      Selector to set size on. (Change in case you have content inside the highlighter you wish to highlight)
      */
      selector_for_set_to_size: ".highlighter",

      /*
      Use CSS watch to watch the element for changes in position and dimensions
      This is only needed if you have javascript or other DOM elements
      that might change the position or size of a switch-enabled element
      Default: false
      */
      watch_for_resize:         false,
      // use_size_position_check:  true

      /*
      The ID for the holder for all highlighters. Unlikely to need changing
      Default: "sw-highlighter-holder"
      */
      holder_id:               "sw-highlighter-holder",

      /*
      Read out the z-index for the element to be highlighted and set to 1 less than the value specified
      on the element.
      If it's set to inherit or auto it will create set z-index 5371 on the element and 5370 on the highlighter
      */
      auto_z_index:            true
    },

    /*
    Options specific to highlighting
    */
    highlight: {
      /*
      Options specifict to highlighting a switch-element
      */
      element: {
        /*
        The class when a element is active/currently selected
        Default: "current"
        */
        current_class:         "current",

        /*
        The class when a group is active/currently selected
        Default: "current"
        */
        group_current_class:      "current_group",

        /*
        The class when set on a switch-element when activated
        action is triggered
        Note: options.visual.delay_before_activating_element must
        be greater than 0
        Default: "activate"
        */
        activate_class:        "activate"
      }
    },

    debug: false,

    /*
    Internal options, but can be changed if needed
    */
    internal: {
      /*
      The data attribute for the unique ID on each element and switch highlighter
      Default: "sw-elem"
      */
      unique_element_data_attribute: "sw-elem",

      /*
      Set a unique class on each element
      Default: false
      */
      set_unique_element_class:      false
    }
  },

  /*
  Actions (Enumish)
  These should not be overridden, as they are used internally
  */
  actions: {
    none:                     0,
    moved_to_next_element:    1,
    moved_to_next_level:      2,
    moved_to_previous_level:  3,
    triggered_action:         10,
    triggered_delayed_action: 11,
    stayed_at_element:        20
  }
};



class SwitchAccess {
  constructor(options) {
    // return existing instance if already initialized, as there should only be one instance of Switch Access on a page
    if ((typeof (window['__switch_access_sci']) !== "undefined") && (window['__switch_access_sci'] !== null)) {
      window.__switch_access_sci.setoptions(options);
      return window.__switch_access_sci;
    }

    window.__switch_access_sci = this;
    /*
    Options
    */
    this.options = {
      /*
      Switch/Key settings
      */
      switches: {

        /*
        The number of switches 0 = disable, 1 = single switch, 2 = two switches
        Default: 2
        */
        number_of_switches:                  0,

        /*
        Array for the keycodes to use as single switch (Multiple keycodes possible)
        Default: [32, 13]  (32 = 'Space', 13 = 'Enter')
        */
        keys_1:                              [32, 13], // Space / Enter

        /*
        Array of two arrays for the keys to use as two switches
        Default: [[32, 9], [13]] (9 = 'Tab, 32 = 'Space', 13 = 'Enter')
        */
        keys_2:                              [[9, 32], [13]], // Tab + Space / Enter

        //keys_3:                             # forward/backward and select

        /*
        Time for single switch scanning to move from element to element
        Default: 1500 milliseconds
        */
        single_switch_move_time:             1500,

        /*
        If the single switch movement should restart/go to index 0 when restarted
        Default: true
        */
        single_switch_restart_on_activate:   true,

        /*
        Time after "triggering" a element to it's activated
        Default: 0
        */
        delay_before_activating_element:     0,

        /*
        Delay before an keypress is "allowed" after last keypress.
        Default: 250 ms
        */
        delay_for_allowed_keypress:          250,

        /*
        Groups enabled/disabled (If elements should be grouped or run as single elements)
        Default: true
        */
        groups:                              true,

        /*
        Set css class on group when highlighting
        Default: true
        */
        groups_highlight_class:              true
      },

      /*
      DOM options
      */
      dom: {
        /*
        The class which all elements must have to be a switch controlled element
        The class should be appended with numbers 1,2,3 etc to set order of elements.
        order is unpredicaable if several elements have the same number within a group.
        Use classnames switch-element-1 switch-element-2 or change this value
        Default: "switch-element-"
        */
        element_class:            "switch-element-",
        /*
        The jQuery selector from where the first switch element should be searched for.
        Usually this should be body or the first container on the webpage
        Note: Use a selector which selects a single object. Else behaviour is unpredictable
        */
        start_element_selector:   "body"
      },

      /*
      Other settings
      */
      // Use .search where you have class="search" or #search for id="search" (jQuery selectors)
      key_filter_skip:        [".search"],

      /*
      If set to true, the first link within the element is "clicked".
      Else the actual element is clicked.
      FUTURE feature: (on the todo list)
      A data attribute can be set on the element in order to override this on a per-element basis
      */
      activate_first_link:    true, // activate element or first link within
      /*
      Enable/Disable debug
      Note: log4javascript must be available if used
      Default: false
      */
      debug:                  false,

      /*
      Visual settings
      */
      visual: {
        /*
        Scroll to ensure the entire element in focus is visible (if possible)
        Default: true
        */
        ensure_visible_element: true, // ensure element is visible on the page

        /*
        The number of pixels for margin to the viewport/window when
        the element is positioned in the viewport/window
        Default: 15
        */
        scroll_offset:          15,

        /*
        Time in milliseconds the scroll will animate
        (set to 0 if instant scroll is preferred)
        Default: 200
        */
        animate_scroll_time:    200,
        /*
        The easing to use for animation
        Default: "linear"
        */
        easing:                 "linear"
      } // easing to use for scrolling
    };

        // hide_show_delay:        500
        // move_fade_delay:        200
        // pulsate:                false
        // play_sound:             false
        // highlight_sound:        "./switch_move.mp3"
        // activate_sound:         "./switch_activate.mp3"

    /*
    Runtime properties
    */
    this.runtime = {
      active:             false, // switchaccess is active or not
      element_list:       null, // an array with root elements
      current_list:       null, // the current list
                               // (Root or an elements list of children)

      parent_list:        null, // the list the parent is in after going into
                               // the group and highlighting the first child

      element: {
        current:          null,  // the current element within the active group
        idx:              0,     // the current element idx within the active group
        level:            0,     // the current level within a group or nested group
        next_level:       0,     // next level when moving to elements.
        next_idx:         0,     // next elements idx
        parent_idx:       0
      },     // the last idx on the parent before moving into the group
      action_triggered:   false, // set to true if an action is triggered
      keypress_allowed:   true,  // keypress allowed or not
      single_switch: {
        timer_id: null,            // The id of the single switch timer
        running: false,            // if the timer is running or not
        activate_triggered: false
      }, // if the activate action has been triggered

      highlighter_holder: null  // The highlighter holder as a jquery object
    };

    this.setoptions(options);
    this.init();
  }

  init() {
    if (this.options.debug) {
      let appender = null;
      this.logger = log4javascript.getLogger();
      if ($('iframe[id*=log4javascript]').length <= 0) {
        if ($('#logger').length > 0) {
          appender = new log4javascript.InPageAppender("logger");
          appender.setWidth("100%");
          appender.setHeight("100%");
        } else {
          appender = new log4javascript.InPageAppender();
          appender.setHeight("500px");
        }

        appender.setThreshold(log4javascript.Level.ALL);
        this.logger.setLevel(log4javascript.Level.ALL);
        this.logger.addAppender(appender);
      }
    }

    if (this.options.debug) { this.log("init"); }
    if (SwitchAccessCommon.options.highlighter.use) { this.createHighlighterHolder(); }
    this.registerCallbacks();
    return this.start();
  }

  setoptions(options) {
    if (this.runtime.active === true) { this.stop(); }
    jQuery.extend(true, SwitchAccessCommon.options, {
      highlighter: options.highlighter,
      highlight:   options.highlight,
      internal:    options.internal,
      debug:       options.debug
    });
    delete options.highlighter;
    delete options.highlight;
    delete options.internal;
    jQuery.extend(true, this.options, options);
  }

  log(msg, type, raw) {
    //console.log msg if @options.nested_debug
    if (type == null) { type = "debug"; }
    if (raw == null) { raw = false; }
    if (this.options.debug) {
      if (raw) {
        return this.logger[type](msg);
      } else {
        return this.logger[type](`SwitchAccess: ${msg}`);
      }
    }
  }

  checkForNonNumberedElements() {
    if ($(`.${this.options.dom.element_class}`).length > 0) {
      let msg = `Warning! ${$(`.${this.options.dom.element_class}`).length} element(s) without numbers found. Class selector is: ${this.options.element_class}.`;
      if (this.options.debug) { this.log(msg, "warning"); }
      console.log(`SwitchAccess: ${msg}`); // Alert about no-numbered elements
    }
  }

  buildListFromjqElement(jq_element, parent, depth) {
    if (depth == null) { depth = 0; }
    let not_str = `[class*=${this.options.dom.element_class}] [class*=${this.options.dom.element_class}]`;
    let i = 0;
    while (i < depth) {
      not_str += ` [class*=${this.options.dom.element_class}]`;
      i++;
    }

    let temp_list = jq_element.find(`[class*=${this.options.dom.element_class}]:visible`).not(not_str);
    if (this.options.debug) { this.log(`buildListFromjqElement - element count ${temp_list.length} depth: ${depth} element-classes:${jq_element.attr("class")}`, "trace"); }
    if (temp_list.length <= 0) { return []; }
    // warn if there are any elements that don't have any numbers
    return this.hashAlizeAndRecurseList(this.sortList(temp_list, this.options.dom.element_class), parent, depth);
  }

  hashAlizeAndRecurseList(list, parent, depth) {
    let ret = [];
    let i = 0;
    while (i < list.length) {
      let new_element = new SwitchAccessElement($(list[i]), this.runtime.highlighter_holder, this, parent);
      new_element.children(this.buildListFromjqElement($(list[i]), new_element, depth + 1 ));
      ret.push( new_element );
      i++;
    }
    return ret;
  }

  sortList(list, list_class) {
    if (this.options.debug) { this.log(`sortList Sorting list for ${list_class} Elements: ${list.length}`); }
    let search_regexp_class = new RegExp(`${list_class}\\d+`);
    let search_regexp_num = new RegExp(`\\d+`);
    list.sort((a,b) => {
      let item_class_name_a = search_regexp_class.exec($(a).attr("class"));
      let item_class_name_b = search_regexp_class.exec($(b).attr("class"));
      let num_a = 0;
      let num_b = 0;
      if ((item_class_name_a !== null) && (item_class_name_b !== null)) {
        num_a = search_regexp_num.exec(item_class_name_a);
        num_b = search_regexp_num.exec(item_class_name_b);
      }
      return num_a - num_b;
    });
    return list;
  }

  elementWithoutChildren(element) {
    if (this.options.debug) { this.log(`elementWithoutChildren ${element.uniqueDataAttr()}`); }
    let ret = [];
    if (element.children().length === 0) {
      ret.push(element);
    } else {
      for (let child of Array.from(element.children())) { ret = ret.concat(this.elementWithoutChildren(child)); }
      element.children([]); // remove children from the element
      element.destroy(); // destroy the element, as the children have been returned
    }
    return ret;
  }


  flattenElementList() {
    if (this.options.debug) { this.log("flattenElementList"); }
    let new_list = [];
    for (let element of Array.from(this.runtime.element_list)) { new_list = new_list.concat(this.elementWithoutChildren(element)); }
    return new_list;
  }

  buildElementList() {
    this.runtime.element_list = this.buildListFromjqElement($(this.options.dom.start_element_selector), null, 0);

    // if groups are disabled, flatten the list by moving children upwards
    if (this.options.switches.groups === false) {
      this.runtime.element_list = this.flattenElementList();
    }

    if (this.options.debug) { this.log(`buildElementList: count:${this.runtime.element_list.length}, class-name: ${this.options.dom.element_class}`); }
  }

  deinit() {
    if (this.options.debug) { this.log("deinit"); }
    this.stop();
    return this.removeHighlightdiv();
  }

  start() {
    if ((this.options.switches.number_of_switches === 0) || (this.runtime.active === true)) { return; }
    if (this.options.debug) { this.log("start"); }
    this.buildElementList();
    // return
    this.runtime.active = true;
    this.moveToFirstRootElement();
    this.startSingleSwitchTimer();
    return this.runtime.action_triggered = false;
  }

  stop() {
    if (this.runtime.active === false) { return; }
    if (this.options.debug) { this.log("stop"); }
    this.runtime.active = false;
    this.removeHighlight();
    this.removeActivateClass();
    return this.stopSingleSwitchTimer();
  }

  destroy() {
    if (this.options.debug) { this.log("destroy"); }
    this.stop();
    this.removeCallbacks();
    this.destroy_elements(this.runtime.element_list);
    this.removeHighlighterHolder();
    this.runtime.element_list       = null;
    this.runtime.current_list       = null;
    this.runtime.parent_list        = null;
    this.runtime.element.current    = null;
    this.runtime.highlighter_holder = null;
    return window.__switch_access_sci  = null;
  }

  /*
  Destroy elements in a list
  Children of the element will be destroyed by the element itself
  */
  destroy_elements(list) {
    if (this.options.debug) { this.log("destroy_elements", "trace"); }
    for (let element of Array.from(list)) { element.destroy(); }
  }

  moveToFirstRootElement() {
    this.runtime.element.idx = -1;
    return this.moveToNextElementAtLevel();
  }

  moveToNextElementAtLevel() {
    if (this.options.debug) { this.log("moveToNextElementAtLevel", "trace"); }
    this.runtime.element.next_idx = this.runtime.element.idx + 1;
    // verify that next idx is possible for "root"
    if ((this.runtime.element.next_level === this.runtime.element.level) && (this.runtime.element.level === 0)) {
      if (this.runtime.element.next_idx >= this.runtime.element_list.length) {
        this.runtime.element.next_idx = 0;
      }
    }

    // see if we should move "out" of the current group
    if (this.runtime.element.next_level !== 0) {
      if (this.runtime.element.next_idx >= this.runtime.current_list.length) {
        return this.moveToPreviousLevel();
      }
    }

    if (this.moveToNext()) {
      this.runtime.element.current.jq_element().triggerHandler("switch-access-move", [this.runtime.element.idx, this.runtime.element.level, this.runtime.element.current]);
      return SwitchAccessCommon.actions.moved_to_next_element;
    } else {
      return SwitchAccessCommon.actions.stayed_at_element;
    }
  }

  moveToNextLevel() {
    if (this.options.debug) { this.log("moveToNextLevel", "trace"); }
    // "catch" if the current element doesn't have children
    if (this.runtime.element.current.children().length > 1) {
      this.runtime.element.next_level = this.runtime.element.level + 1;
      this.runtime.element.next_idx   = 0;
    }

    if (this.moveToNext()) {
      this.runtime.element.current.parent().jq_element().triggerHandler("switch-access-enter-group", [this.runtime.element.idx, this.runtime.element.level, this.runtime.element.current]);
      return SwitchAccessCommon.actions.moved_to_next_level;
    } else {
      return SwitchAccessCommon.actions.stayed_at_element;
    }
  }

  moveToPreviousLevel() {
    if (this.options.debug) { this.log("moveToPreviousLevel", "trace"); }
    this.runtime.element.next_level = this.runtime.element.level - 1;
    this.runtime.element.next_idx = this.runtime.element.parent_idx;
    // safety catch impossible levels
    if (this.runtime.element.next_level < 0) {
      this.runtime.element.next_level = 0;
      this.runtime.element.next_idx = 0;
    }

    if (this.moveToNext()) {
      this.runtime.element.current.jq_element().triggerHandler("switch-access-leave-group", [this.runtime.element.idx, this.runtime.element.level, this.runtime.element.current]);
      return SwitchAccessCommon.actions.moved_to_previous_level;
    } else {
      return SwitchAccessCommon.actions.stayed_at_element;
    }
  }

  moveToNext() {
    let list_n;
    if (this.options.debug) { this.log(`moveToNext Current: I: ${this.runtime.element.next_idx} L: ${this.runtime.element.level} Next: I: ${this.runtime.element.next_idx} L: ${this.runtime.element.next_level}`); }
    this.runtime.action_triggered = true;
    this.runtime.single_switch.activate_triggered = false;

    // return if current level and idxs are equal
    if ((this.runtime.element.next_level === this.runtime.element.level) && (this.runtime.element.idx === this.runtime.element.next_idx)) { return false; }

    this.removeHighlight();

    // find list to work on element
    if (this.runtime.element.next_level > this.runtime.element.level) {
      list_n = this.runtime.element.current.children();
      this.runtime.element.parent_idx = this.runtime.element.idx;
      this.runtime.parent_list = this.runtime.current_list;
      this.runtime.element.next_idx = 0;
    } else if (this.runtime.element.next_level < this.runtime.element.level) {
      this.runtime.element.next_idx = this.runtime.element.parent_idx;
      if (this.runtime.element.current.parent() !== null) {
        list_n = this.runtime.parent_list;
      } else {
        list_n = this.runtime.element_list;
      }
    } else if (this.runtime.element.next_level === 0) {
      list_n = this.runtime.element_list;
    } else {
      list_n = this.runtime.current_list;
    }

    list_n[this.runtime.element.next_idx].highlight();

    this.runtime.element.idx     = this.runtime.element.next_idx;
    this.runtime.element.level   = this.runtime.element.next_level;
    this.runtime.current_list    = list_n;
    this.runtime.element.current = list_n[this.runtime.element.idx];

    // check if this is a "stay-element" and it's single switch
    if (this.options.switches.number_of_switches === 1) {
      if (this.runtime.element.current.jq_element().data("sw-single-stay") === true) {
        this.stopSingleSwitchTimer();
      }
    }

    this.makeElementVisible();
    return true;
  }

  removeHighlight() {
    if (this.options.debug) { this.log("removeHighlight"); }
    if (this.runtime.element.current === null) { return; }
    this.runtime.element.current.removeHighlight();
  }

  removeActivateClass() {
    if (this.options.debug) { this.log("removeHighlight"); }
    if (this.runtime.current_list === null) { return; }
    if (this.runtime.element.current.children().length === 0) {
      this.runtime.element.current.removeActivateClass();
    } else {
    // else it's most likely that the children should be highlighted
      for (let child of Array.from(this.runtime.element.current.children())) { child.removeActivateClass(); }
    }
  }

  /*
  Make the element(s) visible. If the current selected element is a group, they are all moved inside the visible area of the screen
  */
  makeElementVisible() {
    if (this.options.visual.ensure_visible_element !== true) { return; }
    if (this.options.debug) { this.log("makeElementVisible", "trace"); }
    let scrollval = null;
    let scroll_top = $(document).scrollTop();
    let element = this.runtime.element.current.jq_element();
    // positive scroll:
    if (($(window).height() + scroll_top) < (element.offset().top + element.outerHeight() + this.options.visual.scroll_offset)) {
      let diff_to_make_visible = (element.offset().top + element.outerHeight() + this.options.visual.scroll_offset) - ($(document).scrollTop() + $(window).height());
      if (diff_to_make_visible > 0) {
        scrollval = diff_to_make_visible + scroll_top;
      }
    // negative scroll:
    } else if (scroll_top > (element.offset().top - this.options.visual.scroll_offset)) {
      if ((element.offset().top - this.options.visual.scroll_offset) < 0) {
        scrollval = 0;
      } else {
        scrollval = element.offset().top - this.options.visual.scroll_offset;
      }
    }

    if ((scroll_top !== scrollval) && (scrollval !== null)) {
      if (this.options.visual.animate_scroll_time === 0) {
        // for FF
        $("html").scrollTop(scrollval);
        // for Chrome
        return $("html body").scrollTop(scrollval);
      } else {
        // for FF
        $("html").animate({scrollTop: scrollval}, this.options.visual.animate_scroll_time, this.options.visual.easing);
        // for Chrome
        return $("html body").animate({scrollTop: scrollval}, this.options.visual.animate_scroll_time, this.options.visual.easing);
      }
    }
  }


  activateElement() {
    if (this.options.debug) { this.log("activateElement"); }
    this.runtime.action_triggered = true;
    this.stopSingleSwitchTimer();

    if (this.options.debug) { this.log(`Activate Element: idx: ${this.runtime.element.idx} level: IDX: ${this.runtime.element.level} uuid: ${this.runtime.element.current.uniqueDataAttr()}`); }
    if (this.options.switches.delay_before_activating_element === 0) {
      return this.activateElementCallBack();
    } else {
      this.runtime.element.current.jq_element().addClass(this.options.element_activate_class);
      if (this.runtime.element.current.children().length > 0) {
        for (let child of Array.from(this.runtime.element.current.children())) { child.addActivateClass(); }
      } else {
        this.runtime.element.current.addActivateClass();
      }

      window.setTimeout(( () => { this.removeActivateClass(); this.activateElementCallBack(); }), this.options.switches.delay_before_activating_element);
      return SwitchAccessCommon.actions.triggered_delayed_action;
    }
  }

  activateElementCallBack() {
    let el, element_to_click;
    if (this.options.debug) { this.log("activateElementCallBack"); }

    // see if the element has more than 1 child, if so go into level
    if (this.runtime.element.current.children().length > 1) {
      this.startSingleSwitchTimer();
      return this.moveToNextLevel();
    }
    // else the element should "activate"

    // choose correct element to "activate"
    // first child if there is one
    if (this.runtime.element.current.children().length === 1) {
      el = $(this.runtime.element.current.jq_element()[0]); // This might not always be a jquery object.
    } else { // activate the current element
      el = this.runtime.element.current.jq_element();
    }

    if ((el.is("a")) || (this.activate_first_link === false)) {
      element_to_click = el;
    } else {
      // if element isn't a link, find first link within element and go to the url/trigger it
      element_to_click = el.find("a");
    }

    // safety catch
    if (element_to_click.length <= 0) {
      element_to_click = el;
    }

    if (this.options.debug) { this.log(`Triggering Element: IDX: ${this.runtime.element.current_idx} Element Tag: ${$(element_to_click).get(0).tagName.toLowerCase()} Text: ${$(element_to_click).text()}`); }

    this.runtime.element.current.jq_element().triggerHandler("switch-access-activate", [this.runtime.element.idx, this.runtime.element.level, element_to_click, this.runtime.element.current]);
    if (element_to_click.length > 0) {
      element_to_click[0].click(); //trigger("click")
      // if (ret == true) && element_to_click.is("a")
      //   document.location = element_to_click.attr("href")
      if (this.options.switches.number_of_switches === 1) {
        if (this.options.single_switch_restart_on_activate) { this.runtime.next_element_idx = -1; }
        this.runtime.next_level       = 0;
      }
        // @startSingleSwitchTimer()
    } else {
      let msg = "Nothing to do. Verify options passed to SwitchAccess";
      if (this.options.debug) { this.log(msg, "warn"); }
      console.log(`SwitchAccess: Warning: ${msg}`);
      return SwitchAccessCommon.actions.none;
    }

    return SwitchAccessCommon.actions.triggered_action;
  }


  singleSwitchTimerCallback() {
    if (this.options.debug) { this.log("singleSwitchTimerCallback", "trace"); }
    return this.moveToNextElementAtLevel();
  }

  allowKeyPressCallback() {
    if (this.options.debug) { this.log("allowKeyPressCallback", "trace"); }
    return this.runtime.keypress_allowed = true;
  }

  createHighlighterHolder() {
    if ($(`div#${SwitchAccessCommon.options.holder_id}`).length === 0) {
      this.runtime.highlighter_holder = $(`<div id=\"${SwitchAccessCommon.options.highlighter.holder_id}\"></div>`);
      $('body').append(this.runtime.highlighter_holder);
    }
  }

  removeHighlighterHolder() {
    return $(`div#${SwitchAccessCommon.options.highlighter.holder_id}`).remove();
  }

  callbackForKeyPress(event) {
    if (this.options.debug) { this.log(`callbackForKeyPress keycode: ${event.which} Allowed: ${this.runtime.keypress_allowed}`); }
    if (this.options.switches.number_of_switches === 0) { return; }
    let action = 0;

    if (this.options.switches.number_of_switches === 1) {
      if (Array.from(this.options.switches.keys_1).includes(event.which)) {
        if (!this.runtime.keypress_allowed) {
          event.stopPropagation();
          return false;
        }
        // check if stayed at element and if element has "trigger" action
        if (this.runtime.element.current.jq_element().data("sw-single-stay") === true) {
          if ((this.runtime.element.current.jq_element().data("sw-single-noaction") === true) || (this.runtime.single_switch.activate_triggered === true)) {
            action = this.moveToNextElementAtLevel();
            if (this.runtime.element.current.jq_element().data("sw-single-stay") !== true) {
              this.startSingleSwitchTimer();
            }
          } else {
            this.runtime.single_switch.activate_triggered = true;
          }
        }

        if (action === 0) {
          action = this.activateElement();
        }
      }

    } else if (this.options.switches.number_of_switches === 2) {
      if ((Array.from(this.options.switches.keys_2[0]).includes(event.which)) || (Array.from(this.options.switches.keys_2[1]).includes(event.which))) {
        if (!this.runtime.keypress_allowed) {
          event.stopPropagation();
          return false;
        }
      }
      if (Array.from(this.options.switches.keys_2[0]).includes(event.which)) { action = this.moveToNextElementAtLevel(); }
      if (Array.from(this.options.switches.keys_2[1]).includes(event.which)) { action = this.activateElement(); }
    }

    if (this.runtime.action_triggered) {
      this.runtime.action_triggered = false;
      this.runtime.keypress_allowed = false;
      let timeout = this.options.switches.delay_for_allowed_keypress;
      if ((action === SwitchAccessCommon.actions.triggered_action) || (action === SwitchAccessCommon.actions.triggered_delayed_action)) {
        if (this.options.switches.number_of_switches === 1) {
          if (this.options.switches.single_switch_move_time > this.options.switches.delay_before_activating_element) {
            timeout = this.options.switches.single_switch_move_time;
          } else {
            timeout = this.options.switches.delay_before_activating_element;
          }
        } else {
          if (this.options.switches.delay_before_activating_element > timeout) {
            timeout = this.options.switches.delay_before_activating_element;
          }
        }
      }

      if (timeout === 0) {
        this.allowKeyPressCallback();
      } else {
        window.setTimeout((() => { this.allowKeyPressCallback(); }), timeout);
      }

      event.stopPropagation();
      return false;
    } else {
      return true;
    }
  }

  startSingleSwitchTimer() {
    if (this.options.switches.number_of_switches !== 1) { return; }
    if (this.options.debug) { this.log("startSingleSwitchTimer", "trace"); }
    this.runtime.single_switch.timer_id = window.setInterval(( () => { this.singleSwitchTimerCallback(); }), this.options.switches.single_switch_move_time);
    return this.runtime.single_switch.running = true;
  }

  stopSingleSwitchTimer() {
    if (this.options.switches.number_of_switches !== 1) { return; }
    if (this.options.debug) { this.log("stopSingleSwitchTimer", "trace"); }
    window.clearInterval(this.runtime.single_switch.timer_id);
    return this.runtime.single_switch.running = false;
  }

  removeCallbacks() {
    if (this.options.debug) { this.log("removeCallbacks", "trace"); }
    return $(document).off("keydown.switch_access");
  }

  registerCallbacks() {
    if (this.options.debug) { this.log("registerCallbacks", "trace"); }
    $(document).on("keydown.switch_access", event => {
      return this.callbackForKeyPress(event);
    });
  }
}

window.SwitchAccess = SwitchAccess;

class SwitchAccessElement {
  constructor(jq_element, highlight_holder, logger, parent, children) {
    if (highlight_holder == null) { highlight_holder = null; }
    if (logger == null) { logger = null; }
    if (parent == null) { parent = null; }
    if (children == null) { children = []; }
    this.options =
      {debug: false};

    this.runtime = {
      jq_highlighter:   null,         // jquery object of the highlighter belonging to this element
      jq_element,   // jquery object of this element
      uuid:             null,         // The UUID for this element
      watching:         false,        // if csswatch is enabled for this element
      csswatch_init:    false,        // if csswatch has been initialized on/for this element
      parent,       // the parent switch-element of this element
      children,     // the child switch-elements of this element
      highlight_holder: null,         // the highlight holder from SwitchAccess
      element_zidx:     jq_element.css('z-index') // the z-index on the element before modifying it
    };

    this.options.debug = SwitchAccessCommon.options.debug;
    if (this.options.debug) { this.logger = logger; }


    this.runtime.highlight_holder = highlight_holder === null ? $('body') : highlight_holder;

    this.init(this.runtime.highlight_holder);
  }

  init(highlight_holder){
    this.uniqueDataAttr(true);
    this.createHighlighter(highlight_holder);
    if (this.options.debug) { return this.log("init", "trace"); }
  }

  destroy() {
    let jq_element;
    if (this.options.debug) { this.log("destroy", "trace"); }
    this.destroyHighlighter();
    // destroy any children
    for (let child of Array.from(this.children())) { child.destroy(); }

    let parent = null;
    let children = null;
    return jq_element = null;
  }

  parent(parent) {
    if (parent == null) { parent = null; }
    if (parent === null) {
      return this.runtime.parent;
    } else {
      return this.runtime.parent = parent;
    }
  }

  children(children) {
    if (children == null) { children = null; }
    if (children === null) {
      return this.runtime.children;
    } else {
      return this.runtime.children = children;
    }
  }

  jq_element(jq_element) {
    if (jq_element == null) { jq_element = null; }
    if (jq_element === null) {
      return this.runtime.jq_element;
    } else {
      return this.runtime.jq_element = jq_element;
    }
  }

  log(msg, type, raw) {
    if (type == null) { type = "debug"; }
    if (raw == null) { raw = false; }
    if (this.options.debug && (this.logger !== null)) {
      if (raw) {
        this.logger.log(`Element: ${this.runtime.uuid} :`, type);
        return this.logger.log(msg, type, true);
      } else {
        return this.logger.log(`Element: ${this.runtime.uuid} : ${msg}`, type);
      }
    }
  }

  /*
  Trigger the active element, link or event depending on options
  */
  trigger() {
    if (this.options.debug) { return this.log("trigger"); }
  }

  /*
  Show the highlighter and add highlight class to current object
  */
  highlight(check_children) {
    if (check_children == null) { check_children = true; }
    if (this.options.debug) { this.log("highlight"); }
    // if the element has children, it's most likely that the children should be highlighted
    if ((this.children().length > 0) && (check_children === true)) {
      // In any case add the 'group' highlight class
      this.runtime.jq_element.addClass(SwitchAccessCommon.options.highlight.element.group_current_class);
      for (let child of Array.from(this.children())) { child.highlight(false); }
      return;
    }

    // if the next element doesn't have any children, highlight it
    this.runtime.jq_element.addClass(SwitchAccessCommon.options.highlight.element.current_class);
    if (!SwitchAccessCommon.options.highlighter.use) { return; }
    this.runtime.jq_highlighter.addClass(SwitchAccessCommon.options.highlighter.current_class);

    // read element z-index if required
    if (SwitchAccessCommon.options.highlighter.auto_z_index === true) {
      if (isNaN(this.runtime.element_zidx) === true) {
        this.runtime.jq_element.css('z-index', 5371);
        this.runtime.jq_highlighter.css('z-index', 5370);
      } else {
        this.runtime.jq_highlighter.css('z-index', this.runtime.element_zidx - 1);
      }
    }

    this.runtime.jq_highlighter.show();
    // Must show the element before moving, else the offset will not be correct
    this.setHighlighterSizeAndPosition();
    if (SwitchAccessCommon.options.highlighter.watch_for_resize) {
      if (this.runtime.watching === false) {
        return this.enableCSSWatch();
      }
    }
  }

  /*
  Hide highlighter and remove highlight class on the current object(s)
  */
  removeHighlight(check_children) {
    if (check_children == null) { check_children = true; }
    if (this.options.debug) { this.log("removeHighlight"); }

    // if set to check for children:
    if ((this.children().length > 0) && (check_children === true)) {
      // Remove the group class if set
      this.runtime.jq_element.removeClass(SwitchAccessCommon.options.highlight.element.group_current_class);
      for (let child of Array.from(this.children())) { child.removeHighlight(false); }
      return;
    }

    this.runtime.jq_element.removeClass(SwitchAccessCommon.options.highlight.element.current_class);
    this.runtime.jq_element.removeClass(SwitchAccessCommon.options.highlight.element.activate_class);
    if (!SwitchAccessCommon.options.highlighter.use) { return; }
    this.runtime.jq_highlighter.removeClass(SwitchAccessCommon.options.highlighter.current_class);
    this.runtime.jq_highlighter.removeClass(SwitchAccessCommon.options.highlighter.activate_class);
    this.runtime.jq_highlighter.hide();

    if (SwitchAccessCommon.options.highlighter.auto_z_index === true) {
      this.runtime.jq_element.css('z-index', this.runtime.element_zidx);
    }

    if (SwitchAccessCommon.options.highlighter.watch_for_resize) {
      return this.disableCSSWatch();
    }
  }

  addActivateClass() {
    this.runtime.jq_element.addClass(SwitchAccessCommon.options.highlight.element.activate_class);
    if (!SwitchAccessCommon.options.highlighter.use) { return; }
    return this.runtime.jq_highlighter.addClass(SwitchAccessCommon.options.highlighter.activate_class);
  }

  removeActivateClass() {
    if (this.options.debug) { this.log("removeActivateClass"); }
    this.runtime.jq_element.removeClass(SwitchAccessCommon.options.highlight.element.activate_class);
    if (!SwitchAccessCommon.options.highlighter.use) { return; }
    return this.runtime.jq_highlighter.removeClass(SwitchAccessCommon.options.highlighter.activate_class);
  }

  /*
  Set Highlighter size and position
  */
  setHighlighterSizeAndPosition() {
    this.setHighlighterSize(this.runtime.jq_element, this.runtime.jq_highlighter);
    return this.setHighlighterPosition(this.runtime.jq_element, this.runtime.jq_highlighter);
  }

  /*
  Set highlighter position
  */
  setHighlighterPosition(element, highlighter) {
    // posshift = SwitchAccessCommon.options.highlighter.margin_to_element #+ ((highlighter.outerWidth() - highlighter.innerWidth())/2)
    if (this.options.debug) { this.log(`m_to_el: ${SwitchAccessCommon.options.highlighter.margin_to_element}, outerW-innerW: ${highlighter.outerWidth() - highlighter.width()} outerH-innerH: ${highlighter.outerHeight() - highlighter.innerHeight()}`, "trace"); }
    let position = {
      top:  element.offset().top  - SwitchAccessCommon.options.highlighter.margin_to_element - ((highlighter.outerHeight() - highlighter.innerHeight())/2),
      left: element.offset().left - SwitchAccessCommon.options.highlighter.margin_to_element - ((highlighter.outerWidth()  - highlighter.innerWidth())/2)
    };
    if ((highlighter.offset().top === position.top) && (highlighter.offset().left === position.left)) { return; }
    highlighter.offset(position);
    if (this.options.debug) { this.log(`setHighlighterPosition left: ${position.left} top: ${position.top}`, "trace"); }
  }

  /*
  Set size on the Highlighter object to the match the given element
  */
  setHighlighterSize(element, highlighter) {
    let w  = element.outerWidth(false)  + (SwitchAccessCommon.options.highlighter.margin_to_element * 2);
    let h  = element.outerHeight(false) + (SwitchAccessCommon.options.highlighter.margin_to_element * 2);

    highlighter.width(w);
    highlighter.height(h);
    if (this.options.debug) { this.log(`setHighlighterSize w: ${w}, h: ${h}`, "trace"); }
  }

  /*
  Create the highlighter DOM object
  */
  createHighlighter(jq_holder){
    if ((SwitchAccessCommon.options.highlighter.use === false) ||
      (this.runtime.jq_highlighter !== null)) { return; }
    if (this.options.debug) { this.log("createHighlight"); }

    this.runtime.jq_highlighter = $(`<div id=\"sw-el-${this.runtime.uuid}\" class=\"${SwitchAccessCommon.options.highlighter.class}\"></div>`);
    jq_holder.append(this.runtime.jq_highlighter);
    this.runtime.jq_highlighter.css('position','absolute');
    this.runtime.jq_highlighter.hide();
    this.runtime.jq_highlighter.append(SwitchAccessCommon.options.highlighter.content);

    if (SwitchAccessCommon.options.watch_for_resize) {
      // check if content contains selector to use for resizeing
      if (this.runtime.jq_highlighter.find(SwitchAccessCommon.options.highlighter.selector_for_set_to_size).length === 0) {
        return this.runtime.jq_highlighter.addClass(SwitchAccessCommon.options.highlighter.selector_for_set_to_size);
      }
    }
  }

  /*
  Destroy the highlighter DOM object
  */
  destroyHighlighter() {
    if (this.runtime.jq_highlighter === null) { return; }
    if (this.options.debug) { this.log("destroyHighlight", "trace"); }
    this.disableCSSWatch();

    this.runtime.jq_highlighter.remove();
    return this.runtime.jq_highlighter = null;
  }

  /*
  Enable wathcing CSS changes on the element belonging to this object
  */
  enableCSSWatch() {
    if ((SwitchAccessCommon.options.highlighter.use !== true) ||
      (SwitchAccessCommon.options.highlighter.watch_for_resize !== true)) { return; }
    if (this.options.debug) { this.log("enableCSSWatch", "trace"); }
    this.runtime.watching = true;
    if (this.runtime.csswatch_init) {
      return this.runtime.jq_element.csswatch('start');
    } else {
      this.runtime.csswatch_init = true;
      return this.runtime.jq_element.csswatch({
        props: "top,left,bottom,right,width,height",
        props_functions: {
          top:    "offset().top",
          left:   "offset().left",
          bottom: "offset().bottom",
          right:  "offset().right",
          width:  "outerWidth(false)",
          height: "outerHeight(false)"
          },
        callback: (() => {
          return this.callbackForResize();
        }
          )
        });
    }
  }

  /*
  Disable watching CSS changes on the element belonging to this object
  */
  disableCSSWatch() {
    if ((SwitchAccessCommon.options.highlighter.use !== true) ||
      (SwitchAccessCommon.options.highlighter.watch_for_resize !== true)) { return; }
    if (this.options.debug) { this.log("disableCSSWatch", "trace"); }
    this.runtime.watching = false;
    return this.runtime.jq_element.csswatch('stop');
  }

  /*
  Add a data attribute to the element that has a unique ID.
  Will also add the same attribute as a class if option
  set_unique_element_class is enabled.
  */
  uniqueDataAttr(create) {
    if (create == null) { create = false; }
    if (this.options.debug) { this.log(`uniqueDataAttr: Create: ${create}`, "trace"); }
    if (create) {
      this.runtime.uuid = SwitchAccessCommon.generateRandomUUID();
      this.runtime.jq_element.data(SwitchAccessCommon.options.internal.unique_element_data_attribute, this.runtime.uuid);
      if (SwitchAccessCommon.options.set_unique_element_class === true) {
        this.runtime.jq_element.addClass(`${SwitchAccessCommon.options.internal.unique_element_data_attribute}+uuid`);
      }
      return this.runtime.uuid;
    } else {
      return this.runtime.uuid;
    }
  }

  /*
  Callback for resize event on this particular element
  */
  callbackForResize(event, changes) {
    if (this.options.debug) { this.log("callbackForResize", "trace"); }
    if (!SwitchAccessCommon.options.highlighter.use) { return; }
    this.setHighlighterSize(this.runtime.jq_element, this.runtime.jq_highlighter);
    return this.setHighlighterPosition(this.runtime.jq_element, this.runtime.jq_highlighter);
  }
    // if (changes.keys)

  /*
  Play the sound for the current element upon highlight
  */
  // playHighlightSound: ->


  /*
  Play the sound for the current element upon activation
  */
}
  // playActivateSound: ->
