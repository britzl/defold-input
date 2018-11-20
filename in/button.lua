-- Simple input handler for gui nodes. Register nodes and pass any call to
-- on_input() to this module and it will automatically do picking and invoke
-- a registered callback. Example:
--
-- local input_gui = require "in.gui"
--
-- function init(self)
--		input_gui.acquire()
--
-- 		input_gui.register(gui.get_node("blue"), function()
-- 			print("blue")
-- 		end)
--
-- 		input_gui.register("green", function()
-- 			print("green")
-- 			local scale = math.random(1, 5)
-- 			gui.set_scale(gui.get_node("blue"), vmath.vector3(scale, scale, 1))
-- 		end)
-- end
--
-- function final(self)
-- 		input_gui.release()
-- end
--
-- function on_input(self, action_id, action)
-- 		input_gui.on_input(action_id, action)
-- end


local M = {}

M.TOUCH = hash("touch")

local EMPTY_HASH = hash("")

local registered_nodes = {}

local index_count = 0

local function ensure_node(node_or_node_id)
	return type(node_or_node_id) == "string" and gui.get_node(node_or_node_id) or node_or_node_id
end

local function hash_to_hex(h)
	return h and _G.hash_to_hex(h) or ""
end

local function node_to_key(node)
	local url = msg.url()
	local id = gui.get_id(node)
	if id == EMPTY_HASH then
		id = hash("defold-input-button_" .. tostring(index_count))
		gui.set_id(node, id)
		index_count = index_count + 1
	end
	return hash_to_hex(url.socket) .. hash_to_hex(url.path) .. hash_to_hex(url.fragment) .. hash_to_hex(id)
end

--- Convenience function to acquire input focus
function M.acquire()
	msg.post(".", "acquire_input_focus")
end

--- Convenience function to release input focus
function M.release()
	msg.post(".", "release_input_focus")
end

--- Register a node and a callback to invoke when it is clicked
function M.register(node_or_string, callback)
	assert(node_or_string, "You must provide a node")
	assert(callback, "You must provide a callback")
	local node = ensure_node(node_or_string)
	assert(node, "You must provide an existing node or node name")
	local key = node_to_key(node)
	registered_nodes[key] = { url = msg.url(), callback = callback, node = node, scale = gui.get_scale(node) }
	return node
end

--- Unregister a previously registered node or all nodes
-- registered from the calling script
-- @param node_or_string
function M.unregister(node_or_string)
	if not node_or_string then
		local url = msg.url()
		for k,registered_node in pairs(registered_nodes) do
			if registered_node.url == url then
				registered_nodes[k] = nil
			end
		end
	else
		local node = ensure_node(node_or_string)
		assert(node, "You must provide an existing node or node name")
		local key = node_to_key(node)
		assert(registered_nodes[key], "You must provide the id of a registered node")
		registered_nodes[key] = nil
	end
end


function M.dump()
	local url = msg.url()
	for k,registered_node in pairs(registered_nodes) do
		if registered_node.url == url then
			print(k, registered_node.node)
		end
	end
end

local function shake(node, initial_scale)
	gui.cancel_animation(node, "scale.x")
	gui.cancel_animation(node, "scale.y")
	gui.set_scale(node, initial_scale)
	local scale = gui.get_scale(node)
	gui.set_scale(node, scale * 1.2)
	gui.animate(node, "scale.x", scale.x, gui.EASING_OUTELASTIC, 0.8)
	gui.animate(node, "scale.y", scale.y, gui.EASING_OUTELASTIC, 0.8, 0.05, function()
		gui.set_scale(node, initial_scale)
	end)
end

local function is_enabled(node)
	local enabled = gui.is_enabled(node)
	local parent = gui.get_parent(node)
	if not enabled or not parent then
		return enabled
	else
		return is_enabled(parent)
	end
end


local function find_registered_node(x, y)
	local url = msg.url()
	for _,registered_node in pairs(registered_nodes) do
		if registered_node.url == url then
			local node = registered_node.node
			if is_enabled(node) and gui.pick_node(node, x, y) then
				return registered_node
			end
		end
	end
end

--- Forward on_input calls to this function to detect input
-- for registered nodes
-- @param action_id,
-- @param action
-- @return true if input a registerd node received input
function M.on_input(action_id, action)
	if action_id == M.TOUCH then
		if action.pressed then
			local registered_node = find_registered_node(action.x, action.y)
			if registered_node then
				registered_node.pressed = true
				return true
			end
		elseif action.released then
			local registered_node = find_registered_node(action.x, action.y)
			local pressed = registered_node and registered_node.pressed
			local url = msg.url()
			for _,registered_node in pairs(registered_nodes) do
				if registered_node.url == url then
					registered_node.pressed = false
				end
			end
			if pressed then
				shake(registered_node.node, registered_node.scale)
				registered_node.callback()
			end
			return pressed
		end
	end
	return false
end

return M
