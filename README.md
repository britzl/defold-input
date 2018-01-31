# Defold-Input
Defold-Input contains a number of different Lua modules to simplify input detection such as gestures, input mapping and dragging/clicking game objects.

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


# Mapper
Use the Mapper module to map action ids to in-game actions. This makes it very easy to allow the user to rebind keys or to assign different sets of input for the same actions in a multiplayer game. Usage:

	-- setup.script
	local mapper = require "in.mapper"

	function init(self)
		-- bind keys left and right to "move_left" and "move_right" actions for player 1
		mapper.bind(mapper.KEY_LEFT, hash("move_left"), 1)
		mapper.bind(mapper.KEY_RIGHT, hash("move_right"), 1)

		-- bind keys A and D to "move_left" and "move_right" actions for player 2
		mapper.bind(mapper.KEY_A, hash("move_left"), 2)
		mapper.bind(mapper.KEY_D, hash("move_right"), 2)
	end


	-- player.script
	local mapper = require "in.mapper"

	go.property("player_id", 1)

	function on_input(self, action_id, action)
		-- map key to action for
		local action_id = mapper.on_input(action_id, self.player_id)
		if action_id == hash("move_left") then
			print("moving left")
		end
	end


# Cursor
Use the cursor script to simplify user interaction such as clicking and dragging of game objects. Follow these simple instructions to get up and running in minutes:

* Create a game object for the cursor
* Attach a kinematic collision component with a group and mask setup to collide with whatever game objects you wish to interact with
* Attach the cursor script
* Configure the cursor script
