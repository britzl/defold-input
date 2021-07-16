# On-screen
Use the On-screen module to create on-screen/virtual gamepad controls. The module handles buttons and analog sticks.

# Multi-touch
The On-screen module works with multi-touch input if it has been configured in your input bindings. Learn more in the [official Defold documentation](https://defold.com/manuals/input-mouse-and-touch/#touch-triggers).

# Using onscreen.lua
The `onscreen.lua` module can be used directly in any script dealing with user/player input:

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
