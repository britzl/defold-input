# Accelerometer
Use the accelerometer module to simplify the use of the accelerometer sensors as controls on mobile devices. The module can calibrate the accelerometer data based on the current device orientation (along all axis). The module stores multiple samples and provides an average value to reduce the jitter typically seen in accelerometer sensors.

# Usage
You can use the accelerometer using either as the `accelerometer.lua` module or the `accelerometer.script`

## Accelerometer module
Require the module, create an instance or use the global singleton, calibrate, feed it accelerometer samples and read adjusted values:

	local acc = require "in.accelerometer"

	function init(self)
		self.acc = acc.create(20)
		self.acc.calibrate()
	end

	function update(self, dt)
		local adjusted = self.acc.adjusted()
		print(adjusted)
	end

	function on_input(self, action_id, action)
		self.acc.on_input(action)
	end

## Accelerometer script
Attach the `accelerometer.script` to a game object, calibrate, feed it accelerometer samples and read adjusted values via messages:

	function init(self)
		msg.post("#accelerometer", "calibrate")
	end

	function on_message(self, message_id, message, sender)
		if message_id == hash("accelerometer") then
			print(message.x, message.y, message.z)
		end
	end

### Script properties
The script has the following properties:

* `samplecount` - (number) The number of sample to keep in memory and calculate an average for

### Messages
The script will generate messages to game object it is attached to:

* `accelerometer` - Accelerometer data received from the script

The script will accept the following messages:

* `calibrate` - Trigger a calibration of the accelerometer
