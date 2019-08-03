# Input state
Use the State module to keep track of the current state of actions such as if a key or game pad button is pressed or not.

# Usage
You can use the State module in two ways. One is to use the global State module:

	local state = require "in.state"

	function init(self)
		msg.post(".", "acquire_input_focus")
	end

	function update(self, dt)
		if state.is_pressed(hash("move_left")) then
			go.set_position(go.get_position() - vmath.vector3(50, 0, 0) * dt)
		elseif state.is_pressed(hash("move_right")) then
			go.set_position(go.get_position() + vmath.vector3(50, 0, 0) * dt)
		end
	end

	function on_input(self, action_id, action)
		state.on_input(action_id, action)
	end

The other way to use the State module is to create a unique instance. This is useful in multi-player games and when combining the State module with the Mapper module:

	local state = require "in.state"
	local mapper = require "in.mapper"

	function init(self)
		msg.post(".", "acquire_input_focus")
		self.state = state.create()
	end

	function update(self, dt)
		if self.state.is_pressed(hash("move_left")) then
			go.set_position(go.get_position() - vmath.vector3(50, 0, 0) * dt)
		elseif self.state.is_pressed(hash("move_right")) then
			go.set_position(go.get_position() + vmath.vector3(50, 0, 0) * dt)
		end
		-- alternative use
		if state.is_pressed(hash("fire"), self.state) then
			print("Pew pew!")
		end
	end

	function on_input(self, action_id, action)
		self.state.on_input(mapper.on_input(action_id, 1), action)
		-- alternative use
		state.on_input(mapper.on_input(action_id, 1), action, self.state)
	end

# API

### state.acquire([instance])
Acquire input focus

### state.release([instance])
Release input focus

### state.on_input(action_id, action, [instance])
Register the state of an action_id

### state.is_pressed(action_id, [instance])
Check if an action_id is currently registered as pressed

### state.clear([instance])
Clear the state of any registered actions

### state.create()
Create a unique instance of the state tracker
