# Cursor
Use the cursor script to simplify user interaction such as clicking and dragging of game objects.

# Usage
Attach the `cursor.script` to a game object that should act as a cursor. The game object must have either a kinematic or trigger collision object with a group and mask that matches other collision objects that should be able to interact with the cursor.

## Script properties
The script has the following properties:

* `action_id` - (hash) The action_id that corresponds to a press/click/interact action (default: "touch")
* `drag` - (boolean) If the cursor should be able to drag game objects
* `drag_threshold` - (number) Distance the cursor has to move from a pressed object before it's considered dragged
* `acquire_input_focus` - (boolean) Check if the script should acquire input and handle input events itself
* `notify_own_gameobject` - (boolean) Check if cursor messages should be sent not only to the interacting game object but also to the game object this script is attached to.

## Input handling
You can let the cursor react to input in several ways:

* Enable the `acquire_input_focus` property. This will make the script automatically respond to input events. If this isn't checked any `on_input()` calls are completely ignored.
* Pass `input` messages. This will feed input events from an external source. This is useful if the app uses a camera solution or render script where screen coordinates doesn't translate to world coordinates and where conversion is required (using a screen_to_world function or similar). The `input` message is expected to have two fields; `action_id` and `action` in the same way as the `on_input` lifecycle function works.

## Messages
The script will generate messages to game objects the cursor is interacting with and to the game object the cursor script is attached to for the following situations:

* `cursor_over` - The cursors moves over the game object
* `cursor_out` - The cursor moves out from the game object
* `pressed` - When pressing the game object
* `released` - When releasing the game object
* `drag_start` - When starting to drag the game object
* `drag_end` - When no longer dragging the game object

The messages sent to the game object where the cursor script is attached will have `id` and `group` passed in the message.
