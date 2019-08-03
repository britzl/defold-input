local M = {}

local landscape = tonumber(sys.get_config("display.width", 0)) > tonumber(sys.get_config("display.height", 0))

local function is_landscape()
	return landscape
end

local function clamp(x, min, max)
	if x < min then x = min elseif x > max then x = max end
	return x
end

function M.create(samplecount)

	samplecount = samplecount or 20

	local instance = {}

	local samples = {}

	local average = vmath.vector3()
	local zero = vmath.vector3()

	local calibrating = 0

	for i=1,samplecount do
		samples[i] = vmath.vector3()
	end

	local function normalize(value, zero)
		if value > zero then
			return (value - zero) / (1 - zero)
		elseif value < zero then
			return (value - zero) / (1 + zero)
		else
			return 0.0
		end
	end

	local function apply_calibration(v3)
		local calibrated = vmath.vector3(v3)
		calibrated.x = normalize(calibrated.x, zero.x)
		calibrated.y = normalize(calibrated.y, zero.y)
		calibrated.z = normalize(calibrated.z, zero.z)
		return calibrated
	end

	function instance.reset()
		for i=1,samplecount do
			samples[i].x, samples[i].y, samples[i].z = 0, 0, 0
		end
		average.x, average.y, average.z = 0, 0, 0
		zero.x, zero.y, zero.z = 0, 0, 0
	end

	function instance.calibrate()
		calibrating = samplecount
	end

	function instance.on_input(action)
		if not action.acc_x then
			return
		end

		local ax, ay, az = action.acc_x, action.acc_y, action.acc_z

		local current_sample = table.remove(samples, 1)
		current_sample.x, current_sample.y, current_sample.z = ax, ay, az
		table.insert(samples, current_sample)

		average.x, average.y, average.z = 0, 0, 0
		for i=1,#samples do
			local sample = samples[i]
			average.x = average.x + sample.x
			average.y = average.y + sample.y
			average.z = average.z + sample.z
		end
		average.x = average.x / #samples
		average.y = average.y / #samples
		average.z = average.z / #samples

		if calibrating > 0 then
			calibrating = calibrating - 1
			zero.x, zero.y, zero.z = average.x, average.y, average.z
		end
	end

	function instance.calibrated()
		return apply_calibration(average)
	end

	function instance.adjusted()
		local adjusted = vmath.vector3(
			landscape and -average.y or average.x,
			landscape and average.x or average.y,
			average.z)
		return apply_calibration(adjusted)
	end

	function instance.average()
		return average
	end

	function instance.zero()
		return zero
	end

	function instance.latest()
		return samples[#samples]
	end

	function instance.on_window_resized(width, height)
		landscape = width > height
	end

	return setmetatable(instance, {
		__call = function()
			return instance.adjusted()
		end
	})
end


local singleton = M.create()

function M.reset(instance)
	instance = instance or singleton
	return instance.reset()
end

function M.calibrate(instance)
	instance = instance or singleton
	return instance.calibrate()
end

function M.on_input(action, instance)
	instance = instance or singleton
	return instance.on_input(action)
end

function M.calibrated(instance)
	instance = instance or singleton
	return instance.calibrated()
end

function M.adjusted(instance)
	instance = instance or singleton
	return instance.adjusted()
end

function M.average(instance)
	instance = instance or singleton
	return instance.average()
end

function M.zero(instance)
	instance = instance or singleton
	return instance.zero()
end

function M.latest(instance)
	instance = instance or singleton
	return instance.latest()
end

function M.on_window_resized(width, height, instance)
	instance = instance or singleton
	return instance.on_window_resized(width, height)
end


return setmetatable(M, {
	__call = function()
		return M.adjusted()
	end
})