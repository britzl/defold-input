--- Refer to gesture.md for documentation

local M = {}

M.SETTINGS = {
	--- the action to use when detecting gestures
	action_id = hash("touch"),

	--- maximum distance between a pressed and release action to consider it a tap
	tap_threshold = 20,

	--- maximum interval allowed between two taps to consider it a double-tap
	double_tap_interval = 0.5,

	--- minimum distance between a pressed and release action to consider it a swipe
	swipe_threshold = 50,

	--- maximum time between a pressed and release action to consider it a swipe
	swipe_time = 0.5,

	--- minimum time of a pressed/release sequence to consider it a long press
	long_press_time = 0.5,
}


--- Create a gesture instance. Use this if you need multiple gesture detectors that each needs
-- unique settings
-- @param settings
-- @return Gesture instance
function M.create(settings)
	settings = settings or {}
	settings.action_id = settings.action_id or M.SETTINGS.action_id
	settings.tap_threshold = settings.tap_threshold or M.SETTINGS.tap_threshold
	settings.double_tap_interval = settings.double_tap_interval or M.SETTINGS.double_tap_interval
	settings.swipe_threshold = settings.swipe_threshold or M.SETTINGS.swipe_threshold
	settings.swipe_time = settings.swipe_time or M.SETTINGS.swipe_time
	settings.long_press_time = settings.long_press_time or M.SETTINGS.long_press_time

	local instance = {}

	local tap = {
		position = vmath.vector3(),
	}
	local double_tap = {
		position = vmath.vector3(),
	}
	local long_press = {
		position = vmath.vector3(),
	}
	local swipe = {
		from = vmath.vector3(),
		to = vmath.vector3(),
	}
	local gestures = {}

	local pressed
	local pressed_action
	local pressed_time
	local released_time
	local potential_double_tap


	function instance.on_input(action_id, action)
		if action_id ~= settings.action_id then
			return
		end
		gestures.tap = nil
		gestures.double_tap = nil
		gestures.long_press = nil
		gestures.swipe_left = false
		gestures.swipe_right = false
		gestures.swipe_up = false
		gestures.swipe_down = false
		gestures.swipe = nil

		if action.pressed then
			pressed = true
			pressed_action = action
			pressed_time = socket.gettime()
		elseif action.released then
			local dx = pressed_action and (pressed_action.x - action.x) or 0
			local dy = pressed_action and (pressed_action.y - action.y) or 0
			local ax = math.abs(dx)
			local ay = math.abs(dy)
			local distance = math.max(ax, ay)
			local time = socket.gettime() - (pressed_time or 0)
			local is_tap = distance < settings.tap_threshold
			local is_swipe = distance >= settings.swipe_threshold and time <= settings.swipe_time
			if is_tap then
				if potential_double_tap and socket.gettime() - (released_time or 0) < settings.double_tap_interval then
					double_tap.position.x = action.x
					double_tap.position.y = action.y
					gestures.double_tap = double_tap
				end
				if time < settings.long_press_time then
					potential_double_tap = gestures.double_tap == nil
					tap.position.x = action.x
					tap.position.y = action.y
					gestures.tap = tap
				else
					long_press.position.x = action.x
					long_press.position.y = action.y
					long_press.time = time
					gestures.long_press = long_press
					potential_double_tap = false
				end
			elseif is_swipe then
				local vertical = ay > ax
				if vertical and dy < 0 then
					gestures.swipe_up = true
				elseif vertical and dy > 0 then
					gestures.swipe_down = true
				elseif not vertical and dx < 0 then
					gestures.swipe_right = true
				elseif not vertical and dx > 0 then
					gestures.swipe_left = true
				end
				potential_double_tap = false
				swipe.from.x = pressed_action.x
				swipe.from.y = pressed_action.y
				swipe.to.x = action.x
				swipe.to.y = action.y
				swipe.time = time
				gestures.swipe = swipe
			end
			released_time = socket.gettime()
			pressed = false
		end

		return gestures
	end

	return instance
end

local instances = {}

--- Forward calls to on_input to this function to detect supported gestures
-- @param self
-- @param action_id
-- @param action
-- @return A table containing detected gestures. Can contain the following
-- values:
--		* tap [table] Values: position
--		* double_tap [table] Values: position
--		* long_press [table] Values: position, time
--		* swipe_left [boolean]
--		* swipe_right [boolean]
--		* swipe_up [boolean]
--		* swipe_down [boolean]
--		* swipe [table] Values: from, to and time
function M.on_input(self, action_id, action)
	if action_id ~= M.SETTINGS.action_id then
		return
	end
	if not instances[self] then
		instances[self] = M.create(M.SETTINGS)
	end
	return instances[self].on_input(action_id, action)
end

return M
