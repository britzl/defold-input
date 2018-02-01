# Cursor
Use the cursor script to simplify user interaction such as clicking and dragging of game objects.

# Usage
Attach the ```cursor.script``` to a game object that should act as a cursor. The game object must have a kinematic collision object with a group and mask that matches other collision objects that should be able to interact with the cursor.

The script has the following properties:

* ```action_id``` - (hash) The action_id that corresponds to a press/click/interact action
* ```drag``` - (boolean) If the cursor should be able to drag game objects
* ```drag_threshold``` - (number) Distance the cursor has to move from a pressed object before it's considered dragged
* ```acquire_input_focus``` - (boolean) Check if the script should acquire input and handle input events itself

You can let the cursor react to input in several ways:

* Enable the ```acquire_input_focus``` property. This will make the script automatically responding to input events
* Pass "input" messages. This will feed input events from an external source. This is useful if the app uses a camera solution or render script where screen coordinates doesn't translate to world coordinates and where conversion is required (using a screen_to_world function or similar).

The script will generate messages to game objects for the following situations:

* ```cursor_over``` - The cursors moves over the game object
* ```cursor_out``` - The cursor moves out from the game object
* ```pressed``` - When pressing the game object
* ```released``` - When releasing the game object
* ```drag_start``` - When starting to drag the game object
* ``drag_end`` - When no longer dragging the game object
