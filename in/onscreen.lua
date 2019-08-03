local M = {}


M.BUTTON_PRESSED = hash("button_pressed")
M.BUTTON_RELEASED = hash("button_released")
M.ANALOG_PRESSED = hash("analog_pressed")
M.ANALOG_RELEASED = hash("analog_released")
M.ANALOG_MOVED = hash("analog_moved")

-- Create an instance of onscreen controls
-- @param config Optional table with configuration values. Accepted values are:
--		* touch (hash) Action id for the binding to single touch
-- @return instance
function M.create(config)
	config = config or {}
	config.touch = config.touch or hash("touch")

	local instance = {}

	local controls = {}

	local BUTTON = hash("button")
	local ANALOG = hash("analog")

	local function handle_button(control, touch)
		if touch.pressed then
			control.fn(M.BUTTON_PRESSED, control.node, {})
		elseif touch.released then
			control.fn(M.BUTTON_RELEASED, control.node, {})
		end
	end

	local function handle_analog(control, touch)
		local touch_position = vmath.vector3(touch.x, touch.y, 0)
		if touch.pressed then
			gui.cancel_animation(control.node, gui.PROP_POSITION)
			control.analog_pos = touch_position
			control.analog_offset = touch_position - control.node_start_position
			control.fn(M.ANALOG_PRESSED, control.node, { x = 0, y = 0 })
		elseif touch.released then
			gui.animate(control.node, gui.PROP_POSITION, control.node_start_position, gui.EASING_OUTQUAD, 0.2)
			control.fn(M.ANALOG_RELEASED, control.node, { x = 0, y = 0 })
		else
			local diff = control.analog_pos - touch_position
			local dir = vmath.normalize(diff)
			local distance = vmath.length(diff)
			if distance > 0 then
				local radius = control.settings.radius or 80
				if distance > radius then
					touch_position = control.node_start_position - dir * radius
					distance = radius
				else
					touch_position = touch_position - control.analog_offset	
				end
				gui.set_position(control.node, touch_position)
				control.fn(M.ANALOG_MOVED, control.node, { x = -dir.x * distance / radius, y = -dir.y * distance / radius })
			end
		end
	end

	local function find_control_for_xy(x, y)
		for _,control in pairs(controls) do
			if gui.pick_node(control.node, x, y) then
				return control
			end
		end
	end

	local function find_control_for_touch_index(touch_index)
		for _,control in pairs(controls) do
			if control.touch_index == touch_index then
				return control
			end
		end
	end

	local function register_control(node, handler, settings, fn)
		controls[node] = {
			node_start_position = gui.get_position(node),
			node = node,
			pressed = false,
			fn = fn,
			settings = settings,
			handler = handler,
		}
	end

	--- Register an on-screen button
	-- Will generate onscreen.BUTTON_PRESSED and onscreen.BUTTON_RELEASED
	-- @param node The node representing the button
	-- @param settings Optional settings table (currently unused)
	-- @param fn Function to call when button is interacted with
	function instance.register_button(node, settings, fn)
		assert(node, "You must provide a node")
		assert(fn, "You must provide a function")
		settings = settings or {}
		register_control(node, handle_button, settings, fn)
	end

	--- Register an on-screen analog stick
	-- Will generate onscreen.BANALOG_PRESSED, onscreen.ANALOG_RELEASED and onscreen.ANALOG_MOVED
	-- @param node The node representing the analog stick
	-- @param settings Optional settings table. Accepted parameters are:
	--		* radius (number) - Radius of analog stick
	-- @param fn Function to call when analog stick is interacted with
	function instance.register_analog(node, settings, fn)
		assert(node, "You must provide a node")
		assert(fn, "You must provide a function")
		settings = settings or {}
		register_control(node, handle_analog, settings, fn)
	end

	local function handle_touch(touch, touch_index)
		if touch.pressed then
			local control = find_control_for_xy(touch.x, touch.y)
			if control and not control.pressed then
				control.pressed = true
				control.touch_index = touch_index
				control.handler(control, touch)
			end
		elseif touch.released then
			local control = find_control_for_touch_index(touch_index)
			if control then
				control.pressed = false
				control.touch_index = nil
				control.handler(control, touch)
			end
		else
			local control = find_control_for_touch_index(touch_index)
			if control then
				control.handler(control, touch)
			end
		end
	end

	-- Forward any input here
	-- @param action_id
	-- @param action
	function instance.on_input(action_id, action)
		assert(action, "You must provide an action table")
		if action.touch then
			for i,tp in pairs(action.touch) do
				handle_touch(tp, i)
			end
		elseif action_id == config.touch then
			handle_touch(action, 0)
		end
	end
	
	return instance
end


local singleton = M.create()

function M.register_button(node, settings, fn, instance)
	instance = instance or singleton
	return instance.register_button(node, settings, fn)
end

function M.register_analog(node, settings, fn, instance)
	instance = instance or singleton
	return instance.register_analog(node, settings, fn)
end

function M.on_input(action_id, action, instance)
	instance = instance or singleton
	return instance.on_input(action_id, action)
end

return M