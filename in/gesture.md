# Gestures
Use the Gesture module to detect gestures such as swipes, long press and double tap. There are two different ways of using the Gesture module:

## 1 - Using gesture.script
Attach the gesture.script to the game object that should detect gestures. Configure the script properties if necessary. When a gesture is detected the script will generate an "on_gesture" message and send that to the game object.

	function on_message(self, message_id, message, sender)
		if message_id == hash("on_gesture") then
			if message.swipe_right then
				print(message.swipe.from, message.swipe.to)
			elseif message.tap then
				print(message.tap.position)
			elseif message.double_tap then
				print(message.double_tap.position)
			elseif message.long_press then
				print(g.long_press.position, message.long_press.time)
			end
		end
	end

## 2 - Using gesture.lua
Using the gesture module give you full control but requires a couple more lines of code to get started with:

	local gesture = require "in.gesture"

	function init(self)
		msg.post(".", "acquire_input_focus")
	end

	function on_input(self, action_id, action)
		local g = gesture.on_input(self, action_id, action)
		if g then
			if g.swipe_right then
				print(g.swipe.from, g.swipe.to)
			elseif g.tap then
				print(g.tap.position)
			elseif g.double_tap then
				print(g.double_tap.position)
			elseif g.long_press then
				print(g.long_press.position, g.long_press.time)
			end
		end
	end

### Configuration
The Gesture module expects action_id "touch" by default. This and some other configurable values can be changed:

	local gesture = require "in.gesture"

	function init(self)
		gesture.SETTINGS.action_id = hash("interact")	-- Use action_id "interact" to detect gestures
		gesture.SETTINGS.double_tap_interval = 1		-- max 1 second between clicks
		gesture.SETTINGS.long_press_time = 2			-- min 2 seconds for a long press
		gesture.SETTINGS.swipe_threshold = 100			-- min 100 pixels before considering it a swipe
	end

### Using multiple gesture detectors
It's possible to create multiple gesture detectors where each detector has unique settings:

	local gesture = require "in.gesture"

	function init(self)
		self.gestures = gesture.create({
			action_id = hash("interact"),
			double_tap_interval = 1,
			long_press_time = 2,
			swipe_threshold = 100,
		})
	end
