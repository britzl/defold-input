--- Refer to state.md for documentation

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

	--- Clear the state of any currently tracked input states
	function instance.clear()
		action_map = {}
	end

	return instance
end

local singleton = M.create()

--- Acquire input focus for the current script and clear state
-- @param url
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
function M.acquire(url, instance)
	instance = instance or singleton
	return instance.acquire(url)
end

--- Release input focus for the current script and clear state
-- @param url
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
function M.release(url, instance)
	instance = instance or singleton
	return instance.release(url)
end

--- Check if an action is pressed/active
-- @param action_id
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
-- @return true if pressed/active
function M.is_pressed(action_id, instance)
	instance = instance or singleton
	return instance.is_pressed(action_id)
end

--- Forward any calls to on_input from scripts using this module
-- @param action_id
-- @param action
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
function M.update(action_id, action, instance)
	instance = instance or singleton
	return instance.on_input(action_id, action)
end
function M.on_input(action_id, action, instance)
	instance = instance or singleton
	return instance.on_input(action_id, action)
end

--- Clear the state of any currently tracked input states
-- @param instance Optional state instance to modify. Will use global state instance if none is specified
function M.clear(instance)
	instance = instance or singleton
	instance.clear()
end

return M
