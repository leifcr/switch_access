# Switch Access 

*switch_access.coffee* is a coffeescript that enables switch/keyboard control for navigating a webpage for AAC users.

## Features

- 1 or 2 switches
- Switch groups and nested groups
- Switches need to send normal "keys" (e.g. space/enter)
- Lots of options to customize how the switch access works on a page.
- Triggers the a click on the a html element or the first link inside the element (depending on options)

## Usage

### Example

HTML markup:

```html
  <div class"switch-element">
    Div is the switch-element
    <a href="#">link inside a div.</a>
  </div>
  <a href="#" class="switch-element">link is a switch element</a>
  <p class="switch-element"><a href="#">link inside a p.</a></p>
```

Javascript:

```javascript
  $(document).ready(function(){
    window.switch_access = new SwitchAccess({
      switches: {
        number_of_switches: 2
      }
    });
  });
```

### Methods

All methods assume that you initiated the controller similar to the above example.

```javascript
  // start switch access (Done automatically upon construction of object)
  window.switch_access.start() 

  // stop switch access
  window.switch_access.stop() 

  // Remove/Destroy the switch access 
  window.switch_access.destroy()

  // set options. Note: The switch access will stop, so you need to call start after setting options.
  window.switch_access.setoptions({
    switches: {
      number_of_switches: 1,
      single_switch_move_time: 2500 // 2,5 seconds (time is in milliseconds)
    }
  })

```

### Options
```coffeescript
  ###
  Switch/Key settings 
  ###
  switches:

    ### 
    The number of switches 0 = disable, 1 = single switch, 2 = two switches 
    Default: 2
    ###
    number_of_switches:                  0

    ###
    Array for the keycodes to use as single switch (Multiple keycodes possible)
    Default: [32, 13]  (32 = 'Space', 13 = 'Enter')        
    ###
    keys_1:                              [32, 13] # Space / Enter

    ###
    Array of two arrays for the keys to use as two switches
    Default: [[32, 9], [13]] (9 = 'Tab, 32 = 'Space', 13 = 'Enter')        
    ###
    keys_2:                              [[9, 32], [13]] # Tab + Space / Enter
    
    #keys_3:                             # forward/backward and select
    
    ###
    Time for single switch scanning to move from element to element 
    Default: 1500 milliseconds
    ###
    single_switch_move_time:             1500
    
    ###
    If the single switch movement should restart/go to index 0 when restarted
    Default: true
    ###
    single_switch_restart_on_activate:   true

    ###
    Time after "triggering" a element to it's activated 
    Default: 0
    ###
    delay_before_activating_element:     0

    ###
    Delay before an keypress is "allowed" after last keypress.
    Default: 250 ms
    ###
    delay_for_allowed_keypress:          250;

    ###
    Groups enabled/disabled (If elements should be grouped or run as single elements)
    Default: true
    ###
    groups:                              true;

  ###
  DOM options
  ###
  dom:
    ###
    The class which all elements must have to be a switch controlled element
    The class should be appended with numbers 1,2,3 etc to set order of elements. order is unpredicaable if several
    elements have the same number within a group.
    Default: "switch-element-"
    ###
    element_class:            "switch-element-" # Use classnames such as switch-element-1 switch-element-2 or change this value
    ###
    The jQuery selector from where the first switch element should be searched for.
    Usually this should be body or the first container on the webpage
    Note: Use a selector which selects a single object. Else behaviour is unpredictable
    ###
    start_element_selector:   "body"

  ###
  Other settings
  ###
  # Use .search where you have class="search" or #search for id="search" (jQuery selectors)
  key_filter_skip:        [".search"]
  
  ###
  If set to true, the first link within the element is "clicked".
  Else the actual element is clicked.
  FUTURE feature: (on the todo list) 
  A data attribute can be set on the element in order to override this on a per-element basis
  ###
  activate_first_link:    true # activate element or first link within
  ###
  Enable/Disable debug
  Note: log4javascript must be available if used
  Default: false
  ###
  debug:                  false

  ###
  Visual settings
  ###
  visual:
    ###
    Scroll to ensure the entire element in focus is visible (if possible)
    Default: true
    ###
    ensure_visible_element: true # ensure element is visible on the page

    ###
    The number of pixels for margin to the viewport/window when the element is positioned in the viewport/window
    Default: 15
    ###
    scroll_offset:          15 # offset from top/bottom in pixels for the element

    ###
    Time in milliseconds the scroll will last (set to 0 if instant scroll is preferred)
    Default: 200
    ###
    animate_scroll_time:    200 # time to use for animating scroll
    ###
    The easing to use for animation
    Default: "linear"
    ###
    easing:                 "linear" # easing to use for scrolling

  ###
  Element highlighting using the built in Highlighter object feature
  ###
  highlighter:
    ###
    Use highlighter div element for each element.
    A div is positioned absolute around the element and shown/hidden accordingly
    Default: true
    ###
    use:                      true
    
    ###
    Additional content for the highlighter
    Note: The content is placed within every highlighter and multiple highlighters can be visible at the same time.
          It is best to not use ID's on elements placed inside the highlighter
    Default: ""
    ###
    content:                  ""
    
    ###
    Class for the highlighter
    Default: "highlighter"
    ###
    class:                    "highlighter"

    ###
    The class when a highlighter is active/currently selected
    Default: "current"
    ###
    current_class:            "current"

    ###
    The class when set on a highlighter when activated action is triggered 
    Note: only usable if options.visual.delay_before_activating_element is > 0
    Default: "activate"
    ###
    activate_class:           "activate"
    
    ###
    Margin between the highlighter and the element
    Default: 5
    ###
    margin_to_element:        5

    ###
    Selector to set size on. (Change in case you have content inside the highlighter you wish to highlight)
    ###
    selector_for_set_to_size: ".highlighter"
    
    ###
    Use CSS watch to watch the element for changes in position and dimensions
    This is only needed if you have javascript or other DOM elements 
    that might change the position or size of a switch-enabled element
    Default: false
    ###
    watch_for_resize:         false
    # use_size_position_check:  true
    
    ###
    The ID for the holder for all highlighters. Unlikely to need changing
    Default: "sw-highlighter-holder"
    ###
    holder_id:               "sw-highlighter-holder"

  ###
  Options specific to highlighting
  ###
  highlight:
    ###
    Options specifict to highlighting a switch-element
    ###
    element:
      ###
      The class when a element is active/currently selected
      Default: "current"
      ###
      current_class:         "current"

      ###
      The class when set on a switch-element when activated action is triggered 
      Note: only usable if options.visual.delay_before_activating_element is > 0
      Default: "activate"
      ###
      activate_class:        "activate"

```

## Events

There are four events dispatched that can be listened to:
<dl>
  <dt>switch-access-activate</dt>
  <dd>This event is dispatched when a element is activated. Three parameters are sent with the element. 
    <ol>
      <li>The index of the element that has been highlighted/moved to (0-based).</li>
      <li>The level (group level) of the activated element (0-based), where 0 is root</li>
      <li>The clicked element (Either the DOM element that is the switch element or a link inside, depending on options)</li>
      <li>The current element.</li>
    </ol>
  </dd>
  <dt>switch-access-move</dt>
  <dd>This event is dispatched when a element is moved to (highlighted). Two parameters are sent with the element. 
    <ol>
      <li>The index of the element that has been highlighted/moved to (0-based).</li>
      <li>The level (group level) of the activated element (0-based), where 0 is root</li>
      <li>The current element.</li>
    </ol>
  </dd>
  <dt>switch-access-enter-group</dt>
  <dd>This event is dispatched when a group of switch-elements is entered.
    <ol>
      <li>The index of the element that is the parent of the highlighted group/objects (0-based).</li>
      <li>The level (group level) of the highlighted objects</li>
      <li>The element that is the parent of the highlighted group/objects.</li>
    </ol>
  </dd>
  <dt>switch-access-leave-group</dt>
  <dd>This event is dispatched when a group of switch-elements is left.
    <ol>
      <li>The index of the highlighted element (0-based).</li>
      <li>The level (group level) of the highlighted object</li>
      <li>The element that is highlighted.</li>
    </ol>
  </dd>
</dl>


## Requirements

jQuery (1.8 or newer)

##### For development:
log4javascript (http://log4javascript.org) only if debug is set to true

##### For more easings on the scrolling:
http://gsgd.co.uk/sandbox/jquery/easing/

## Browser Compatibility

Chrome
Firefox
Internet Explorer 9+

## License

This work is under either a GPL License or a Commercial license. For commercial usage, please contact (leifcr@gmail.com)

