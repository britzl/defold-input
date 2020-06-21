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

	--- if multi touch gestures should be handled or not
	multi_touch = true,
}


-- Create the state tracking table for a single touch point
local function create_touch_state()
	local state = {}

	state.tap = {
		position = vmath.vector3(),
	}
	state.double_tap = {
		position = vmath.vector3(),
	}
	state.long_press = {
		position = vmath.vector3(),
	}
	state.swipe = {
		from = vmath.vector3(),
		to = vmath.vector3(),
	}

	state.pressed = false
	state.pressed_position = nil
	state.pressed_time = nil
	state.released_time = nil
	state.potential_double_tap = false

	return state
end


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
	if settings.multi_touch == nil then
		settings.multi_touch = M.SETTINGS.multi_touch
	end

	local instance = {}

	-- this is what we return from the gesture detector
	local gestures = {
		two_finger = {},
	}

	-- the state of a single touch
	local single_state = create_touch_state()
	
	-- the state of individual multi touch points
	local multi_states = {}

	local pinch = {
		center = vmath.vector3(),
	}

	local function clear_gesture_state()
		gestures.tap = nil
		gestures.double_tap = nil
		gestures.long_press = nil
		gestures.swipe_left = false
		gestures.swipe_right = false
		gestures.swipe_up = false
		gestures.swipe_down = false
		gestures.swipe = nil

		gestures.two_finger.tap = false
		gestures.two_finger.double_tap = false
		gestures.two_finger.long_press = false
		gestures.two_finger.swipe_left = false
		gestures.two_finger.swipe_right = false
		gestures.two_finger.swipe_up = false
		gestures.two_finger.swipe_down = false
		gestures.two_finger.pinch = nil
	end


	-- handle the state of a touch (either single or one from a multi touch)
	local function handle_touch(touch, state)
		state.is_double_tap = false
		state.is_tap = false
		state.is_long_press = false
		state.is_swipe = false
		state.swipe_left = false
		state.swipe_right = false
		state.swipe_up = false
		state.swipe_down = false
				
		if touch.pressed then
			state.pressed = true
			state.pressed_position = vmath.vector3(touch.x, touch.y, 0)
			state.pressed_time = socket.gettime()
		elseif touch.released then
			local dx = state.pressed_position and (state.pressed_position.x - touch.x) or 0
			local dy = state.pressed_position and (state.pressed_position.y - touch.y) or 0
			local ax = math.abs(dx)
			local ay = math.abs(dy)
			local distance = math.max(ax, ay)
			local time = socket.gettime() - (state.pressed_time or 0)
			local is_tap = distance < settings.tap_threshold
			local is_swipe = distance >= settings.swipe_threshold and time <= settings.swipe_time
			if is_tap then
				if state.potential_double_tap and socket.gettime() - (state.released_time or 0) < settings.double_tap_interval then
					state.is_double_tap = true
					state.was_double_tap = true
					state.double_tap.position.x = touch.x
					state.double_tap.position.y = touch.y
				end
				if time < settings.long_press_time then
					-- a third tap in short succession should not be considered a potential double tap
					state.potential_double_tap = not state.was_double_tap
					state.is_tap = true
					state.was_double_tap = false
					state.tap.position.x = touch.x
					state.tap.position.y = touch.y
				else
					state.potential_double_tap = false
					state.is_long_press = true
					state.was_double_tap = false
					state.long_press.position.x = touch.x
					state.long_press.position.y = touch.y
					state.long_press.time = time
				end
			elseif is_swipe then
				state.is_swipe = true
				state.was_double_tap = false
				local vertical = ay > ax
				if vertical and dy < 0 then
					state.swipe_up = true
				elseif vertical and dy > 0 then
					state.swipe_down = true
				elseif not vertical and dx < 0 then
					state.swipe_right = true
				elseif not vertical and dx > 0 then
					state.swipe_left = true
				end
				state.potential_double_tap = false
				state.swipe.from.x = state.pressed_position.x
				state.swipe.from.y = state.pressed_position.y
				state.swipe.to.x = touch.x
				state.swipe.to.y = touch.y
				state.swipe.time = time
			end
			
			state.released_time = socket.gettime()
			state.pressed = false
		end
	end


	local function handle_single_touch(action)
		clear_gesture_state()
		handle_touch(action, single_state)
		if single_state.is_double_tap then
			gestures.double_tap = single_state.double_tap
		elseif single_state.is_tap then
			gestures.tap = single_state.tap
		elseif single_state.is_long_press then
			gestures.long_press = single_state.long_press
		elseif single_state.is_swipe then
			gestures.swipe = single_state.swipe
			gestures.swipe_up = single_state.swipe_up
			gestures.swipe_down = single_state.swipe_down
			gestures.swipe_right = single_state.swipe_right
			gestures.swipe_left = single_state.swipe_left
		end
	end


	local function handle_multi_touch(action)
		assert(action.touch and #action.touch == 2)
		clear_gesture_state()
		local t1 = action.touch[1]
		local t2 = action.touch[2]

		-- there seems to be an issue with multi touch where the first press
		-- doesn't get registered
		if not multi_states[t1.id] then
			multi_states[t1.id] = create_touch_state()
			t1.pressed = true
		end
		if not multi_states[t2.id] then
			multi_states[t2.id] = create_touch_state()
			t2.pressed = true
		end
		local s1 = multi_states[t1.id]
		local s2 = multi_states[t2.id]
		handle_touch(t1, s1)
		handle_touch(t2, s2)

		if s1.is_double_tap and s2.is_double_tap then
			gestures.two_finger.double_tap = true
		elseif s1.is_tap and s2.is_tap then
			gestures.two_finger.tap = true
		elseif s1.is_long_press and s2.is_long_press then
			gestures.two_finger.long_press = true
		elseif s1.is_swipe and s2.is_swipe then
			gestures.two_finger.swipe_up = s1.swipe_up and s2.swipe_up
			gestures.two_finger.swipe_down = s1.swipe_down and s2.swipe_down
			gestures.two_finger.swipe_right = s1.swipe_right and s2.swipe_right
			gestures.two_finger.swipe_left = s1.swipe_left and s2.swipe_left
		else
			local pressed1 = s1.pressed_position
			local pressed2 = s2.pressed_position
			local pressed_distance = vmath.length(pressed1 - pressed2)

			local pos1 = vmath.vector3(t1.x, t1.y, 0)
			local pos2 = vmath.vector3(t2.x, t2.y, 0)
			local diff = pos2 - pos1
			local distance = vmath.length(diff)
			local direction = vmath.normalize(diff)
			pinch.center = pos1 + direction * distance * 0.5
			pinch.ratio = distance / pressed_distance
			gestures.two_finger.pinch = pinch
		end
	end


	function instance.on_input(action_id, action)
		if action.touch then
			if settings.multi_touch and #action.touch == 2 then
				handle_multi_touch(action)
				return gestures
			end
		elseif action_id == settings.action_id then
			handle_single_touch(action)
			return gestures
		end
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
--		* two_finger [table] Two-finger geatures (tap, double_tap, long_press, swipe_* and pinch)
function M.on_input(self, action_id, action)
	if not instances[self] then
		instances[self] = M.create(M.SETTINGS)
	end
	return instances[self].on_input(action_id, action)
end

return M
