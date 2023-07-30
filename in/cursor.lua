local M = {}

M.OVER = hash("cursor_over")
M.OUT = hash("cursor_out")
M.PRESSED = hash("pressed")
M.RELEASED = hash("released")
M.DRAG = hash("drag")
M.DRAG_END = hash("drag_end")
M.DRAG_START = hash("drag_start")
M.CLICKED = hash("clicked")
M.RESET = hash("reset")

M.START_DRAGGING = hash("start_dragging")

M.DRAG_MODE_HORIZONTAL = hash("drag_mode_horizontal")
M.DRAG_MODE_VERTICAL = hash("drag_mode_vertical")
M.DRAG_MODE_FREE = hash("drag_mode_free")


local listeners = {}

local EMPTY = hash("")

local function url_to_key(url)
	if type(url) == "string" then
		url = msg.url(url)
	else
		url = url or msg.url()
	end
	return hash_to_hex(url.socket or EMPTY) .. hash_to_hex(url.path or EMPTY) ..hash_to_hex(url.fragment or EMPTY)
end

function M.trigger(message_id, message)
	assert(message_id, "You must provide a message id")
	local key = url_to_key()
	local fn = listeners[key][message_id]
	if fn then
		if fn(message_id, message) then
			return false
		end
	end
	return true
end

function M.listen(cursor_url, message_id, fn)
	assert(message_id, "You must provide a message id")
	assert(fn, "You must provide a listener function")
	local key = url_to_key(cursor_url)
	listeners[key] = listeners[key] or {}
	listeners[key][message_id] = fn
end

function M.init()
	local key = url_to_key()
	listeners[key] = listeners[key] or {}
end

function M.final()
	listeners[url_to_key()] = nil
end

function M.reset(cursor_url)
	cursor_url = cursor_url or msg.url()
	msg.post(cursor_url, M.RESET)
end

return M
