# On-screen
Use the On-screen module to create on-screen/virtual gamepad controls. The module handles buttons and analog sticks.

# Multi-touch
The On-screen module works with multi-touch input if it has been configured in your input bindings. Learn more in the [official Defold documentation](https://defold.com/manuals/input-mouse-and-touch/#touch-triggers).

# Using onscreen.lua
In your .gui file's Properties, point the Script property to the [GUI script](https://defold.com/manuals/gui-script/) `onscreen.gui_script` that comes shipped with this library, and register and listen for the buttons with messages. See [player.script](https://github.com/britzl/defold-input/blob/master/examples/onscreen_go/player.script) for a complete implementation example.

---

The `onscreen.lua` module can be used directly in any script dealing with user/player input.

- As an example, create a new GUI script ([see docs here](https://defold.com/manuals/gui-script/)) and add this code:

```lua
local onscreen = require "in.onscreen"

local function on_control(action, node, touch)
	if action == onscreen.BUTTON then
		if touch.pressed then
			print("pressed button", touch.id)
		elseif touch.released then
			print("released button", touch.id)
		end
	elseif action == onscreen.ANALOG then
		if touch.pressed then
			print("pressed analog", touch.id)
		elseif touch.released then
			print("released analog", touch.id)
		else
			print("moved analog", touch.id, touch.x, touch.y)
		end
	elseif action == onscreen.ANALOG_UP then
		if touch.pressed then
			print("analog stick is pushed up beyond specified threshold")
		end
	end
end

function init(self)
	onscreen.register_analog(gui.get_node("analog"), { radius = 80, threshold = 0.9 }, on_control)
	onscreen.register_button(gui.get_node("button_a"), nil, on_control)
end

function final(self)
	onscreen.reset()
end

function on_input(self, action_id, action)
	onscreen.on_input(action_id, action)
end
```

- Then attach this new GUI script to your GUI.

- Inside your GUI, add two UI nodes with id "analog" and "button_a".

- See [controls.gui_script](https://github.com/britzl/defold-input/blob/master/examples/onscreen_gui/controls.gui_script) for a complete implementation example.
