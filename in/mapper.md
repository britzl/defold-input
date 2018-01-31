Use the Mapper module to map action ids to in-game actions. This makes it very easy to allow the user to rebind keys or to assign different sets of input for the same actions in a multiplayer game.

# Using mapper.lua

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

# Using mapper.script
