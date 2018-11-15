local unload = require "deftest.util.unload"
local mock = require "deftest.mock.mock"
local mock_gui = require "deftest.mock.gui"
local button = require "in.button"

return function()

	describe("button", function()
		before(function()
			button = require "in.button"
			mock_gui.mock()
		end)

		after(function()
			mock_gui.unmock()
			unload.unload("in.button")
		end)

		it("should be possible to click on a button", function()
			local btn1 = mock_gui.add_box(hash("btn1"), 10, 10, 200, 40)
			local btn2 = mock_gui.add_box(hash("btn2"), 10, 60, 200, 40)

			local btn1_click = 0
			local btn2_click = 0
			button.register("btn1", function() btn1_click = btn1_click + 1 end)
			button.register(btn2, function() btn2_click = btn2_click + 1 end)

			button.on_input(hash("touch"), { pressed = true, x = 10, y = 10 })
			button.on_input(hash("touch"), { released = true, x = 10, y = 10 })
			assert(btn1_click == 1)
			assert(btn2_click == 0)
			
			button.on_input(hash("touch"), { pressed = true, x = 10, y = 60 })
			button.on_input(hash("touch"), { released = true, x = 10, y = 60 })
			assert(btn1_click == 1)
			assert(btn2_click == 1)
		end)

		it("should ignore invalid clicks", function()
			local btn1 = mock_gui.add_box(hash("btn1"), 10, 10, 200, 40)

			local btn1_click = 0
			button.register("btn1", function() btn1_click = btn1_click + 1 end)

			-- pressed inside, released outside
			button.on_input(hash("touch"), { pressed = true, x = 10, y = 10 })
			button.on_input(hash("touch"), { released = true, x = 1000, y = 1000 })

			-- pressed outside, released inside
			button.on_input(hash("touch"), { pressed = true, x = 1000, y = 1000 })
			button.on_input(hash("touch"), { released = true, x = 10, y = 10 })

			assert(btn1_click == 0)
		end)

		it("should be possible to unregister a button", function()
			local btn1 = mock_gui.add_box(hash("btn1"), 10, 10, 200, 40)
			local btn2 = mock_gui.add_box(hash("btn2"), 10, 60, 200, 40)

			local btn1_click = 0
			local btn2_click = 0
			button.register("btn1", function() btn1_click = btn1_click + 1 end)
			button.register("btn2", function() btn2_click = btn2_click + 1 end)
			button.unregister("btn1")
			button.unregister(btn2)

			button.on_input(hash("touch"), { pressed = true, x = 10, y = 10 })
			button.on_input(hash("touch"), { released = true, x = 10, y = 10 })
			button.on_input(hash("touch"), { pressed = true, x = 10, y = 60 })
			button.on_input(hash("touch"), { released = true, x = 10, y = 60 })

			assert(btn1_click == 0)
			assert(btn2_click == 0)
		end)

		it("should be possible to unregister all buttons", function()
			local btn1 = mock_gui.add_box(hash("btn1"), 10, 10, 200, 40)
			local btn2 = mock_gui.add_box(hash("btn2"), 10, 60, 200, 40)

			local btn1_click = 0
			local btn2_click = 0
			button.register("btn1", function() btn1_click = btn1_click + 1 end)
			button.register("btn2", function() btn2_click = btn2_click + 1 end)
			button.unregister()

			button.on_input(hash("touch"), { pressed = true, x = 10, y = 10 })
			button.on_input(hash("touch"), { released = true, x = 10, y = 10 })
			button.on_input(hash("touch"), { pressed = true, x = 10, y = 60 })
			button.on_input(hash("touch"), { released = true, x = 10, y = 60 })

			assert(btn1_click == 0)
			assert(btn2_click == 0)
		end)
	end)
end
