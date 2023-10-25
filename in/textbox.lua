-- Simple input handler for gui nodes. Register nodes and pass any call to
-- on_input() to this module to select and write text into textbox.
-- Example:
--
-- local textbox = require "in.textbox"
--
-- function init(self)
--		textbox.acquire()
--
-- 		textbox.register("login_box_node", "login_text_node")
--		textbox.register("pswd_box_node", "pswd_text_node", true)
--		textbox.text("login_box_note", "admin")
-- end
--
-- function final(self)
-- 		textbox.release()
-- end
--
-- function on_input(self, action_id, action)
-- 		textbox.on_input(action_id, action)
-- end

local M = {}

M.TOUCH = hash("touch")
M.TYPE = hash("text")
M.BACKSPACE = hash("key_backspace")

local EMPTY_HASH = hash("")

local registered_nodes = {}

local selected_textbox = nil

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
		id = hash("defold-input-textbox_" .. tostring(index_count))
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

--- Register box and text nodes and optional mask param
-- Use is_mask = true if you want to show asterisks (*) instead of the text
function M.register(box_node_or_string, text_node_or_string, is_masked)
	assert(box_node_or_string, "You must provide a node for box")
	assert(text_node_or_string, "You must provide a node for text")

	local box_node = ensure_node(box_node_or_string)
	assert(box_node, "You must provide an existing node or node name for box")
	
	local text_node = ensure_node(text_node_or_string)
	assert(text_node, "You must provide an existing node or node name for text")
	
	local key = node_to_key(box_node)
	registered_nodes[key] = { 
		url = msg.url(), 
		text_node = text_node, 
		box_node = box_node, 
		scale = gui.get_scale(box_node), 
		is_masked = is_masked == true 
	}
	return box_node
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

function M.effect(node, scale)
	gui.cancel_animation(node, "scale.x")
	gui.cancel_animation(node, "scale.y")
	gui.animate(node, "scale.x", scale.x, gui.EASING_OUTCUBIC, 1)
	gui.animate(node, "scale.y", scale.y, gui.EASING_OUTCUBIC, 1)
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
			local node = registered_node.box_node
			if is_enabled(node) and gui.pick_node(node, x, y) then
				return registered_node
			end
		end
	end
end

-- Update textbox label of selected textbox
local function update(node)
	if node.is_masked then
		local len = string.len(node.text)
		gui.set_text(node.text_node, string.rep("*", len))
	else
		gui.set_text(node.text_node, node.text)
	end
end

local function get_registered_node(node_or_string)
	local node = ensure_node(node_or_string)
	assert(node, "You must provide an existing node or node name")
	local key = node_to_key(node)
	assert(registered_nodes[key], "You must provide the id of a registered node")
	return registered_nodes[key]
end

-- Set and get text of any registered textbox
function M.text(node_or_string, text)
	registered_node = get_registered_node(node_or_string)
	if text then
		registered_node.text = text
		update(registered_node)
	end
	return registered_node.text
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
			else
				if selected_textbox then
					M.effect(selected_textbox.box_node, selected_textbox.scale)
				end
				selected_textbox = nil
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
				if selected_textbox and selected_textbox ~= registered_node then
					M.effect(selected_textbox.box_node, selected_textbox.scale)
				end
				selected_textbox = registered_node
				if not registered_node.text then
					registered_node.text = ""
				end
				M.effect(registered_node.box_node, registered_node.scale * 1.1)
			end
			return pressed
		end
	elseif selected_textbox and action_id == M.TYPE then
		selected_textbox.text = selected_textbox.text .. action.text
		update(selected_textbox)

	elseif selected_textbox and action_id == M.BACKSPACE and action.repeated then
		local len = string.len(selected_textbox.text)
		selected_textbox.text = string.sub(selected_textbox.text, 0, len - 1)
		update(selected_textbox)
	end
	return false
end

return M
