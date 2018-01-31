--- Module to keep track of pressed and released states for all
-- input that it receives.
--
-- @usage
--
-- -- Alternative with a global state tracker
-- -- script1
-- local input_state = require "in.state"
-- 
-- function init(self)
-- 	input_state.acquire()
-- end
-- 
-- function final(self)
-- 	input_state.release()
-- end
-- 
-- function update(self, dt)
-- 	if input_state.is_pressed(hash("left")) then
-- 		go.set_position(go.get_position() - vmath.vector3(50, 0, 0) * dt)
-- 	elseif input_state.is_pressed(hash("right")) then
-- 		go.set_position(go.get_position() + vmath.vector3(50, 0, 0) * dt)
-- 	end
-- end
-- 
-- function on_input(self, action_id, action)
-- 	input_state.on_input(action_id, action)
-- end
--
-- -- Alternative with a script local state tracker
-- -- script2
-- local input_state = require "in.state"
-- 
-- function init(self)
--	self.input_state = input_state.create()
-- 	self.input_state.acquire()
-- end
-- 
-- function final(self)
-- 	self.input_state.release()
-- end
-- 
-- function update(self, dt)
-- 	if self.input_state.is_pressed(hash("left")) then
-- 		go.set_position(go.get_position() - vmath.vector3(50, 0, 0) * dt)
-- 	elseif self.input_state.is_pressed(hash("right")) then
-- 		go.set_position(go.get_position() + vmath.vector3(50, 0, 0) * dt)
-- 	end
-- end
-- 
-- function on_input(self, action_id, action)
-- 	self.input_state.on_input(action_id, action)
-- end
--

local M = {}

--- Create an instance of the input state tracker
-- @return State instance
function M.create()
	local instance = {}

	local action_map = {}

	--- Acquire input focus for the current script
	-- @param url
	function instance.acquire(url)
		msg.post(url or ".", "acquire_input_focus")
		action_map = {}
	end

	--- Release input focus for the current script
	-- @param url
	function instance.release(url)
		msg.post(url or ".", "release_input_focus")
		action_map = {}
	end

	--- Check if an action is currently pressed or not
	-- @param action_id
	-- @return true if action_id is pressed
	function instance.is_pressed(action_id)
		assert(action_id, "You must provide an action_id")
		action_id = type(action_id) == "string" and hash(action_id) or action_id
		return action_map[action_id]
	end

	--- Forward any calls to on_input from scripts using this module
	-- @param action_id
	-- @param action
	function instance.on_input(action_id, action)
		assert(action, "You must provide an action")
		if action_id then
			action_id = type(action_id) == "string" and hash(action_id) or action_id
			if action.pressed then
				action_map[action_id] = true
			elseif action.released then
				action_map[action_id] = false
			end
		end
	end
	
	return instance
end

local instance = M.create()

--- Acquire input focus for the current script
-- @param url
function M.acquire(url)
	return instance.acquire(url)
end

--- Release input focus for the current script
-- @param url
function M.release(url)
	return instance.release(url)
end

--- Check if an action is pressed/active
-- @param action_id
-- @return true if pressed/active
function M.is_pressed(action_id)
	return instance.is_pressed(action_id)
end

--- Forward any calls to on_input from scripts using this module
-- @param action_id
-- @param action
function M.update(action_id, action)
	return instance.on_input(action_id, action)
end
function M.on_input(action_id, action)
	return instance.on_input(action_id, action)
end

return M
