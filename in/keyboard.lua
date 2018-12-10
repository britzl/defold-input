local M = {}

M.KEYBOARD_INPUT = hash("keyboard_input")


local current_text = nil

local timer_handle = nil

local HTML5 = sys.get_sys_info().system_name == "HTML5"

local ELEMENT_ID = "___defold-input-keyboard"
local ELEMENT = ("document.getElementById('%s')"):format(ELEMENT_ID)


local function log(text)
	print(text)
	msg.post(".", "log", { text = text })
end

-- we need to delete and recreate the input field since
-- it's seems like changing field type isn't always allowed
-- (at least not changing from password to text)
local function create_keyboard(keyboard_type)
	local type_lookup = {
		[gui.KEYBOARD_TYPE_DEFAULT] = "text",
		[gui.KEYBOARD_TYPE_EMAIL] = "email",
		[gui.KEYBOARD_TYPE_NUMBER_PAD] = "number",
		[gui.KEYBOARD_TYPE_PASSWORD] = "password",
	}

	html5.run(([[
	var id = "%s";
	var e = document.getElementById(id);
	if (e) {
		e.parentNode.removeChild(e);
	}
	e = document.createElement("input");
	console.log("created", e);
	e.setAttribute('type', '%s');
	e.setAttribute('value', '');
	e.id = id;
	e.style = "position:absolute; left:-10000px; top:auto; width:1px; height:1px; overflow:hidden; pointer-events:none;";
	document.body.appendChild(e);
	]]):format(ELEMENT_ID, type_lookup[keyboard_type] or "text"))
end

local function show_keyboard(keyboard_type)
	create_keyboard(keyboard_type)
	html5.run(ELEMENT .. ".value = '';")
	html5.run(ELEMENT .. ".focus();")
end

local function hide_keyboard()
	html5.run(ELEMENT .. ".blur();")
end

local function has_focus()
	return html5.run(ELEMENT .. " == document.activeElement;") == "true"
end

function M.show(keyboard_type)
	--log("show")
	keyboard_type = keyboard_type or gui.KEYBOARD_TYPE_DEFAULT
	if not HTML5 then
		gui.show_keyboard(keyboard_type, false)
		return
	end

	show_keyboard(keyboard_type)
	if timer_handle then
		--log("stopping timer")
		timer.cancel(timer_handle)
		timer_handle = nil
	end

	timer_handle = timer.delay(0.05, true, function()
		if not has_focus() and timer_handle then
			--log("timer lost focus")
			timer.cancel(timer_handle)
			timer_handle = nil
		end
		local text = html5.run(ELEMENT .. ".value")
		if text ~= current_text then
			current_text = text
			msg.post(".", M.KEYBOARD_INPUT, { text = text })
		end
	end)
end

function M.hide()
	if HTML5 then
		--log("hide")
		hide_keyboard()
	else
		gui.hide_keyboard()
	end
end



return M