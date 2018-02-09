local mock = require "deftest.mock"

return function()
	local state = require "in.state"

	describe("state", function()
		before(function()
			mock.mock(msg)
			msg.post.replace(function() end)
		end)

		after(function()
			mock.unmock(msg)
		end)

		it("should post a message to acquire input focus", function()
			state.acquire()
			assert(msg.post.calls == 1)
			assert(msg.post.params[1] == ".")
			assert(msg.post.params[2] == "acquire_input_focus")
		end)

		it("should post a message to release input focus", function()
			state.release()
			assert(msg.post.calls == 1)
			assert(msg.post.params[1] == ".")
			assert(msg.post.params[2] == "release_input_focus")
		end)

		it("should keep track of pressed and released state of action ids", function()
			local action_id1 = hash("action1")
			local action_id2 = hash("action2")
			local pressed = { pressed = true }
			local released = { released = true }

			assert(not state.is_pressed(action_id1))
			assert(not state.is_pressed(action_id2))

			state.on_input(action_id1, pressed)
			assert(state.is_pressed(action_id1))
			assert(not state.is_pressed(action_id2))

			state.on_input(action_id2, pressed)
			assert(state.is_pressed(action_id1))
			assert(state.is_pressed(action_id2))

			state.on_input(action_id1, released)
			assert(not state.is_pressed(action_id1))
			assert(state.is_pressed(action_id2))

			state.on_input(action_id2, released)
			assert(not state.is_pressed(action_id1))
			assert(not state.is_pressed(action_id2))
		end)

		it("should only care about action.pressed and action.released", function()
			local action_id = hash("action")
			local pressed = { pressed = true }
			local released = { released = true }
			local repeated = { repeated = true }

			state.on_input(action_id, repeated)
			assert(not state.is_pressed(action_id))

			state.on_input(action_id, pressed)
			assert(state.is_pressed(action_id))

			state.on_input(action_id, repeated)
			assert(state.is_pressed(action_id))

			state.on_input(action_id, released)
			assert(not state.is_pressed(action_id))
		end)

		it("should handle both string and hash as action_id", function()
			local action_id_hash = hash("action1")
			local action_id_string = hash("action1")
			local pressed = { pressed = true }
			local released = { released = true }

			assert(not state.is_pressed(action_id_string))
			assert(not state.is_pressed(action_id_hash))

			state.on_input(action_id_string, pressed)
			assert(state.is_pressed(action_id_string))
			assert(state.is_pressed(action_id_hash))

			state.on_input(action_id_string, released)
			assert(not state.is_pressed(action_id_string))
			assert(not state.is_pressed(action_id_hash))

			state.on_input(action_id_hash, pressed)
			assert(state.is_pressed(action_id_string))
			assert(state.is_pressed(action_id_hash))
		end)


		it("should be able to create multiple instances", function()
			local action_id1 = hash("action1")
			local action_id2 = hash("action2")
			local pressed = { pressed = true }
			local released = { released = true }

			local state1 = state.create()
			local state2 = state.create()

			assert(not state1.is_pressed(action_id1))
			assert(not state1.is_pressed(action_id2))
			assert(not state2.is_pressed(action_id1))
			assert(not state2.is_pressed(action_id2))

			state1.on_input(action_id1, pressed)
			assert(state1.is_pressed(action_id1))
			assert(not state2.is_pressed(action_id1))

			state2.on_input(action_id2, pressed)
			assert(state1.is_pressed(action_id1))
			assert(not state2.is_pressed(action_id1))
			assert(not state1.is_pressed(action_id2))
			assert(state2.is_pressed(action_id2))

			state1.on_input(action_id1, released)
			assert(not state1.is_pressed(action_id1))
			state2.on_input(action_id2, released)
			assert(not state2.is_pressed(action_id2))
		end)
	end)
end
