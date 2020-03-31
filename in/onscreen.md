# On-screen
Use the On-screen module to create on-screen/virtual gamepad controls. The module handles buttons and analog sticks.

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
		end
	end

	function init(self)
		onscreen.register_analog(gui.get_node("analog"), { radius = 80 }, on_control)
		onscreen.register_button(gui.get_node("button_a"), nil, on_control)
	end

	function final(self)
		onscreen.reset()
	end

	function on_input(self, action_id, action)
		onscreen.on_input(action_id, action)
	end
