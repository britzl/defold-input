# Button
Simple input handler for gui nodes that should act as buttons. Register nodes and pass any call to on_input() to this module and it will automatically do picking and invoke a registered callback.

# Usage
The Button module can be used via ```button.lua```:

	local button = require "in.button"

	function init(self)
		msg.post(".", "acquire_input_focus")

		button.register(gui.get_node("blue"), function()
			print("blue")
		end)

		button.register("green", function()
			print("green")
			local scale = math.random(1, 5)
			gui.set_scale(gui.get_node("blue"), vmath.vector3(scale, scale, 1))
		end)
	end

	function final(self)
		button.unregister("blue")
		button.unregister("green")
	end

	function on_input(self, action_id, action)
		button.on_input(action_id, action)
	end
