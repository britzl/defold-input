# Gestures
Use the Gesture module to detect gestures such as swipes, long press and double tap. It also supports two finger gestures. You can use the Gesture module either via the ```gesture.script``` or directly via ```gesture.lua```.

# Using gesture.script
Attach the ```gesture.script``` to the game object that should detect gestures. Configure the script properties if necessary. When a gesture is detected the script will generate an ```on_gesture``` message and send that to the game object.

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

Configuration of the Gesture module when using the ```gesture.script``` is done via the exposed script properties. Select the script when it's attached to a game object and modify the settings from the Properties panel of the editor. See [Configuration](#configuration).

# Using gesture.lua
Using the gesture module directly gives you full control but requires a couple of lines of code to get started with:

	local gesture = require "in.gesture"

	function init(self)
		msg.post(".", "acquire_input_focus")
		gesture.SETTINGS.double_tap_interval = 1
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
			elseif g.two_finger.tap then
				print("Two finger tap!")
			elseif g.two_finger.pinch then
				print(g.two_finger.pinch.ratio, g.two_finger.center)
			end
		end
	end

It's possible to create multiple gesture detectors where each instance has unique settings:

	local gesture = require "in.gesture"

	function init(self)
		self.gesture = gesture.create({
			action_id = hash("interact"),
			double_tap_interval = 1,
			long_press_time = 2,
			swipe_threshold = 100,
		})
	end

	function on_input(self, action_id, action)
		local g = self.gesture.on_input(self, action_id, action)
		if g then
			-- handle gestures here
		end
	end

Configuration is done via the ```gesture.SETTINGS.*``` table or via a settings table passed into ```gesture.create(settings)```. In both cases the accepted configuration values can be seen in the [Configuration section](#configuration).

# Configuration
The Gesture module has the following configuration options:

* ```action_id``` - (hash) The action_id to use when detecting gestures (default: "touch")
* ```double_tap_interval``` - (number) Maximum time in seconds between two taps to consider it as a double tap (default: 0.5)
* ```long_press_time``` - (number) Minimum time in seconds before a tap is considered a long press (default: 0.5)
* ```swipe_threshold``` - (number) Minimum distance in pixels before considering it a swipe (default: 100)
* ```tap_threshold``` - (number) Maximum distance in pixels between a press and release action to consider it a tap (default: 20)
* ```multi_touch``` - (boolean) If multi touch gestures should be handled or not (default: true)
