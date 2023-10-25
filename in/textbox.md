# Textbox
Simple input handler for gui nodes that should act as textboxes. Register nodes and pass any call to on_input() to this module to select and write text into textbox.

# Usage
The Textbox module can be used via ```textbox.lua```:

    local textbox = require "in.textbox"

    function init(self)
		textbox.acquire()

 		textbox.register("login_box_node", "login_text_node")
		textbox.register("pswd_box_node", "pswd_text_node", true)
		textbox.text("login_box_note", "admin")
    end

    function final(self)
 		textbox.release()
    end

    function on_input(self, action_id, action)
 		textbox.on_input(action_id, action)
    end
