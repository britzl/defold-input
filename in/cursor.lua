local M = {}

M.OVER = hash("cursor_over")
M.OUT = hash("cursor_out")
M.PRESSED = hash("pressed")
M.RELEASED = hash("released")
M.DRAG = hash("drag")
M.DRAG_END = hash("drag_end")
M.DRAG_START = hash("drag_start")
M.CLICKED = hash("clicked")

local listeners = {}

local EMPTY = hash("")

local function url_to_key(url)
	url = url or msg.url()
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
	assert(listeners[key], "You must provide a valid cursor script url")
	listeners[key][message_id] = fn
end

function M.init()
	listeners[url_to_key()] = {}
end

function M.final()
	listeners[url_to_key()] = nil
end
	
return M