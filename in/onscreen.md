# On-screen
Use the On-screen module to create on-screen/virtual gamepad controls. The module handles buttons and analog sticks.

# Using onscreen.lua
The `onscreen.lua` module can be used directly in any script dealing with user/player input:

	local function on_analog(action, control, touch)
		if action == onscreen.ANALOG_PRESSED then
			print("analog pressed")
		elseif action == onscreen.ANALOG_RELEASED then
			print("analog released")
		elseif action == onscreen.ANALOG_MOVED then
			print("analog moved", touch.x, touch.y)
		end
	end

	local function on_control_a(action, control, touch)
		if action == onscreen.BUTTON_PRESSED then
			print("button_a pressed")
		elseif action == onscreen.BUTTON_RELEASED then
			print("button_a released")
		end
	end

	function init(self)
		onscreen.register_analog(gui.get_node("analog"), { radius = 80 }, on_analog)
		onscreen.register_button(gui.get_node("button_a"), nil, on_control_a)
	end

	function final(self)
		onscreen.reset()
	end

	function on_input(self, action_id, action)
		onscreen.on_input(action_id, action)
	end
