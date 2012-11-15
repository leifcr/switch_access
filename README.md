# Switch Access 

*switch-access.coffee* is a coffeescript that enables switch/keyboard control for navigating a webpage for AAC users.

## Features

- 1 or 2 switches
- Switches need to send normal "keys" (e.g. space/enter)
- Various options for setting up the controller.
- Triggers the first link inside the element that is highlighted, unless the element itself is a link
- Will restart if any options are set while it's running.

## Usage

### Example
```
  <div class"switch-element">
    Div is the switch-element
    <a href="#">link inside a div.</a>
  </div>
  <a href="#" class="switch-element">link is a switch element</a>
  <p class="switch-element"><a href="#">link inside a p.</a></p>
```

```javascript
  $(document).ready(function(){
    window.switch_access = new SwitchAccess({
      number_of_switches: 2
    });
  });
```

### Methods

All methods assume that you initiated the controller similar to the above example.

```javascript
  # start switch access (Done automatically upon construction of object)
  window.switch_access.start() 

  # stop switch access
  window.switch_access.stop() 

  # Deinitialize (Must be done before deleting object)
  window.switch_access.deinit()
  delete window.switch_access

  window.switch_access.setoptions({
    number_of_switches: 1,
    single_switch_move_time: 2500 // 2,5 seconds (time is in milliseconds)
    })

```


### Options
<dl>
  <dt>number_of_switches</dt>
  <dd>The number of switches 0 = disable, 1 = single switch, 2 = two switches <br/><em>Default: 0</em></dd>
  <dt>keys_1</dt>
  <dd>Array for the keys to use as single switch (Multiple keys possible), the keycode is required to function. <br/><em>Default: [32, 13] (32 = 'Space', 13 = 'Enter')</em></dd>
  <dt>keys_2</dt>
  <dd>Array or two arrays for the keys to use as two switches (Multiple keys possible). <br/><em>Default: [[32], [13]] (32 = 'Space', 13 = 'Enter')</em></dd>
  <dt>element_class</dt>
  <dd>The class which all elements must have to be a switch controlled element <br/><em>Default: "switch-element"</em></dd>
  <dt>activate_element_class</dt>
  <dd>The classname for the element when it's activated <em>Default: "switch-highlight-activate"</em> </dd>
  <dt>highlight_element_id</dt>
  <dd>The ID and class of the div that will be used to set a "highlight" frame around the given element.<em>Default: "switch-highlight-element"</em></dd>
  <dt>highlight_element_activate_class</dt>
  <dd>The class added to the highlight frame when a link is activated.<em>Default: "switch-highlight-element-activate"</em></dd>
  <dt>hide_show_delay</dt>
  <dd>Time for hide/show fading when starting/stopping the switch control <br/><em>Default: 500</em></dd>
  <dt>move_fade_delay</dt>
  <dd>Time the fade in/out will use when moving from element to element <br/><em>Default: 50</em></dd>
  <dt>pulsate</dt>
  <dd>Not implemented yet. (Do not use) <br/><em>Default: false</em></dd>
  <dt>sort_element_list_after_numbers</dt>
  <dd>Sort the element list after numbers, if the classname is provided with numbers on the elements. <br/><em>Default: true</em></dd>
  <dt>debug</dt>
  <dd>set to true for enabling logging (require log4javascript) <br/><em>Default: false</em></dd>
  <dt>margin_to_element</dt>
  <dd>Margin between the highlight frame and the object to highlight <br/><em>Default: 5 (pixels)<em> </dd>
  <dt>fields_where_keys_should_be_accepted</dt>
  <dd>Fields where the switch controller should not stop keypress propagation <br/><em>Default: ["search"]<em> </dd>
  <dt>use_highlight_div</dt>
  <dd>If a div should be moved as "highlight" on top of the other element. <br/><em>Default: true<em> </dd>
  <dt>highlight_element_class</dt>
  <dd>Class name that should be put on the current "highlighted" elements <br/><em>Default: switch-highlight</em></dd>
  <dt>single_switch_move_time</dt>
  <dd>Time for single switch scanning to move from element to element <br/><em>Default: 1500</em></dd>
  <dt>delay_before_activating_element</dt>
  <dd>Time after "triggering" a element to it's activated <em>Default: 0</em></dd>
  <dt>activate_first_link</dt>
  <dd>"Click" the element if it is a link or the first link within the element, for false it will only "click" the element.<br/><em>Default: true</em></dd>
  <dt>use_outer_sizes</dt>
  <dd>Use outer sizes (including padding and border) of the element to resize the highlight area. Set to false to use element width/height</dd>
  <dt>include_margin_in_outer_size</dt>
  <dd>also include the margin of the element to resize the highlight area.</dd>
  <dt>delay_for_allowed_keypress</dt>
  <dd>Delay before an keypress is "allowed" after last keypress.<em>Default: 250 ms</em></dd>
  <dt>single_switch_restart_on_activate</dt>
  <dd>If the single switch movement should restart/go to index 0 when restarted<em>Default: false</em></dd>
  <dt>highlight_on_activate_time</dt>
  <dd>The time the objects have the classes specified in highlight_element_activate_class and activate_element_class. Note: if a delay for activating is setup, this time starts counting AFTER the actual activation of an element has occured <em>Default: 1000 ms</em> </dd>
</dl>

## Events

There are two events dispatched that can be listened to:
<dl>
  <dt>switch-access-activate</dt>
  <dd>This event is dispatched when a element is activated. Three parameters are sent with the element. 
    <ol><li>The current element (highlighted).</li>
      <li>The index of the activated element (0-based).</li>
      <li>The object that gets the "click" event after the activation of a link.</li>
    </ol>
  </dd>
  <dt>switch-access-move</dt>
  <dd>This event is dispatched when a element is moved to (highlighted). Two parameters are sent with the element. 
    <ol><li>The current element (highlighted).</li>
      <li>The index of the activated element (0-based).</li>
    </ol>
  </dd>
</dl>


## Cookies

Some settings can be read from cookies upon init. (You probably have some sort of user model where you store the data, so you can pass that to a cookie or use the initializer)

The following settings are read from a cookie if available: number of switches, keys_1 and keys_2, and single_switch_move_time

The settings in the cookie will override what you have in the initializer, in case the user customized his/her settings.

## Requirements

jQuery (1.7 or newer)

jQuery-cookie (https://github.com/carhartl/jquery-cookie) (only if you intend to use settings from a cookie)

## Browser Compatibility

Chrome
Firefox
Internet Explorer 9+

## License

This work is under the FreeBSD License.

As this is *free* for use in other products, please consider sending me a gadget if you charge your customers.
