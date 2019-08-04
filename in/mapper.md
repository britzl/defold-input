# Mapper
Use the Mapper module to map action ids to in-game actions. This makes it very easy to allow the user to rebind keys or gamepad button or to assign different sets of input for the same actions in a multiplayer game.

# Input bindings
In order to allow players to bind in-game actions to any key or gamepad button it is recommended to use an `*.input_bindings` file where each Input is bound to an Action. The [all.input_bindings](in/bindings/all-input_bindings) does this and it's recommended to use this file together with the Mapper module. The triggers in `all.input_bindings` exist as constants in `in/triggers.lua`.

# Bind actions to in-game actions
Use the Mapper to define how incoming actions should translate to in-game actions. In the example below key bindings are defined for two players. For player one the KEY_LEFT and KEY_RIGHT (ie cursor keys) keys are bound to the in-game actions "move_left" and "move_right". For player two it is the "A" and "D" keys that are bound to the same in-game actions.

	local mapper = require "in.mapper"
	local triggers = require "in.triggers"

	function init(self)
		-- bindings for player 1
		mapper.bind(triggers.KEY_LEFT, "move_left", 1)
		mapper.bind(triggers.KEY_RIGHT, "move_right", 1)

		-- bindings for player 2
		mapper.bind(triggers.KEY_A, "move_left", 2)
		mapper.bind(triggers.KEY_D, "move_right", 2)

		-- bindings for player 3 using gamepad with index 1
		mapper.bind(triggers.GAMEPAD_LPAD_LEFT, "move_left", 3, 1)
		mapper.bind(triggers.GAMEPAD_LPAD_RIGHT, "move_right", 3, 1)
	end

Once the bindings are defined the Mapper module is ready for use, either via the `mapper.script` or directly via `mapper.lua`.

# Using mapper.script
Attach the `mapper.script` to the same game object as the one that handles player input logic. The script will listen for user input and remap the incoming actions to in-game actions matching the ones specified when setting up the bindings. The script exposes two script properties:

* `acquire_input_focus` - (boolean) Check this to automatically acquire input focus (default: false)
* `player_id` - (number) Assign a player id matching the one used when the input bindings were created (default: 1)
* `gamepad_index` - (number) Assign a gamepad index matching the one used when the input bindings were created (default: 1)

When valid input is received the script will post an `on_input` message to the game object it is attached to. The player logic script should listen for this message and act accordingly:

	function on_message(self, message_id, message, sender)
		if message_id == hash("on_input") then
			if message.action_id == hash("move_left") and message.action.pressed then
				-- move left!
			end
		end
	end

# Using mapper.lua
The `mapper.lua` module can be used directly in any script dealing with user/player input:

	-- player.script
	local mapper = require "in.mapper"

	go.property("player_id", 1)

	function init(self)
		msg.post(".", "acquire_input_focus")
	end

	function on_input(self, action_id, action)
		local action_id = mapper.on_input(action_id, self.player_id)
		if action_id == hash("move_left") and action.pressed then
			-- move left!
		end
	end
