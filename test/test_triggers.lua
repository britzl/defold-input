local triggers = require "in.triggers"

return function()

	describe("triggers", function()
		it("should be able to tell if an event is from a gamepad", function()
			assert(triggers.is_gamepad(triggers.GAMEPAD_LSTICK_LEFT))
			assert(triggers.is_gamepad(triggers.GAMEPAD_LPAD_UP))
			assert(triggers.is_gamepad(triggers.GAMEPAD_RSHOULDER))
			assert(not triggers.is_gamepad(triggers.MOUSE_BUTTON_LEFT))
			assert(not triggers.is_gamepad(triggers.KEY_SPACE))
		end)

		it("should be able to tell if an event is from a mouse", function()
			assert(triggers.is_mouse(triggers.MOUSE_BUTTON_LEFT))
			assert(triggers.is_mouse(triggers.MOUSE_BUTTON_RIGHT))
			assert(triggers.is_mouse(triggers.MOUSE_WHEEL_UP))
			assert(not triggers.is_mouse(triggers.GAMEPAD_LSTICK_LEFT))
			assert(not triggers.is_mouse(triggers.KEY_SPACE))
		end)

		it("should be able to tell if an event is from a keyboard", function()
			assert(triggers.is_key(triggers.KEY_SPACE))
			assert(triggers.is_key(triggers.KEY_A))
			assert(triggers.is_key(triggers.KEY_1))
			assert(not triggers.is_key(triggers.GAMEPAD_RSHOULDER))
			assert(not triggers.is_key(triggers.MOUSE_BUTTON_LEFT))
		end)
	end)
end
