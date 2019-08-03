local mapper = require "in.mapper"
local unload = require "deftest.util.unload"

local INPUT_LEFT = hash("left")
local INPUT_RIGHT = hash("right")
local INPUT_A = hash("a")
local INPUT_D = hash("d")
local INPUT_SPACE= hash("space")

local ACTION_RUN_LEFT = hash("run_left")
local ACTION_RUN_RIGHT = hash("run_right")
local ACTION_JUMP = hash("jump")

return function()
	describe("state", function()
		after(function()
			unload("in.*")
		end)

		it("should be able to bind input to actions", function()
			mapper.bind(INPUT_LEFT, ACTION_RUN_LEFT)
			mapper.bind(INPUT_RIGHT, ACTION_RUN_RIGHT)
			assert(mapper.on_input(INPUT_LEFT) == ACTION_RUN_LEFT, "Expected action run_left")
			assert(mapper.on_input(INPUT_RIGHT) == ACTION_RUN_RIGHT, "Expected action run_right")
			assert(not mapper.on_input(INPUT_SPACE), "Expecte no action")
		end)

		it("should be able to unbind a previously bound action", function()
			mapper.bind(INPUT_LEFT, ACTION_RUN_LEFT)
			mapper.bind(INPUT_RIGHT, ACTION_RUN_RIGHT)
			mapper.unbind(INPUT_RIGHT)
			assert(mapper.on_input(INPUT_LEFT) == ACTION_RUN_LEFT, "Expected action run_left")
			assert(not mapper.on_input(INPUT_RIGHT), "Expected no action")
		end)

		it("should be able to unbind all actions", function()
			mapper.bind(INPUT_LEFT, ACTION_RUN_LEFT)
			mapper.bind(INPUT_RIGHT, ACTION_RUN_RIGHT)
			mapper.unbind_all()
			assert(not mapper.on_input(INPUT_LEFT), "Expected no action")
			assert(not mapper.on_input(INPUT_RIGHT), "Expected no action")
		end)

		it("should be able to bind input to actions and separate per player", function()
			-- player one uses left+right arrow key
			mapper.bind(INPUT_LEFT, ACTION_RUN_LEFT, 1)
			mapper.bind(INPUT_RIGHT, ACTION_RUN_RIGHT, 1)
			-- player two uses a+d
			mapper.bind(INPUT_A, ACTION_RUN_LEFT, 2)
			mapper.bind(INPUT_D, ACTION_RUN_RIGHT, 2)

			assert(mapper.on_input(INPUT_LEFT, 1) == ACTION_RUN_LEFT, "Expected action run_left")
			assert(not mapper.on_input(INPUT_LEFT, 2), "Expected no action")
			assert(mapper.on_input(INPUT_A, 2) == ACTION_RUN_LEFT, "Expected action run_left")
			assert(not mapper.on_input(INPUT_A, 1), "Expected no action")
		end)

		it("should be able to unbind input for a specific player", function()
			-- player one uses left+right arrow key
			mapper.bind(INPUT_LEFT, ACTION_RUN_LEFT, 1)
			mapper.bind(INPUT_RIGHT, ACTION_RUN_RIGHT, 1)
			-- player two uses a+d
			mapper.bind(INPUT_A, ACTION_RUN_LEFT, 2)
			mapper.bind(INPUT_D, ACTION_RUN_RIGHT, 2)

			mapper.unbind(INPUT_LEFT, 1)
			mapper.unbind(INPUT_D, 2)
			
			assert(mapper.on_input(INPUT_RIGHT, 1), "Expected action run_right")
			assert(mapper.on_input(INPUT_A, 2), "Expected action run_left")
			assert(not mapper.on_input(INPUT_LEFT, 1), "Expected no action")
			assert(not mapper.on_input(INPUT_D, 2), "Expected no action")
		end)

		it("should be able to unbind all actions for a specific player", function()
			-- player one uses left+right arrow key
			mapper.bind(INPUT_LEFT, ACTION_RUN_LEFT, 1)
			mapper.bind(INPUT_RIGHT, ACTION_RUN_RIGHT, 1)
			-- player two uses a+d
			mapper.bind(INPUT_A, ACTION_RUN_LEFT, 2)
			mapper.bind(INPUT_D, ACTION_RUN_RIGHT, 2)
			mapper.unbind_all(1)
			assert(not mapper.on_input(INPUT_LEFT, 1), "Expected no action")
			assert(not mapper.on_input(INPUT_RIGHT, 1), "Expected no action")
			assert(mapper.on_input(INPUT_A, 2), "Expected action run_left")
			assert(mapper.on_input(INPUT_D, 2), "Expected action run_right")
		end)

		it("should be able to bind input to actions and a specific gamepad", function()
			mapper.bind(INPUT_LEFT, ACTION_RUN_LEFT, 1, 1)
			mapper.bind(INPUT_RIGHT, ACTION_RUN_RIGHT, 1, 1)
			assert(mapper.on_input(INPUT_LEFT, 1) == ACTION_RUN_LEFT, "Expected action run_left")
			assert(mapper.on_input(INPUT_RIGHT, 1) == ACTION_RUN_RIGHT, "Expected action run_right")
			assert(mapper.on_input(INPUT_LEFT, 1, 1) == ACTION_RUN_LEFT, "Expected action run_left")
			assert(mapper.on_input(INPUT_RIGHT, 1, 1) == ACTION_RUN_RIGHT, "Expected action run_right")
			assert(not mapper.on_input(INPUT_LEFT, 1, 2), "Expected no action")
			assert(not mapper.on_input(INPUT_RIGHT, 1, 2), "Expected no action")
			assert(not mapper.on_input(INPUT_LEFT, 2, 2), "Expected no action")
			assert(not mapper.on_input(INPUT_RIGHT, 2, 2), "Expected no action")
		end)
			
	end)
end
