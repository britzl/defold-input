![](logo.jpeg)

[![Build Status](https://travis-ci.org/britzl/defold-input.svg?branch=master)](https://travis-ci.org/britzl/defold-input)

# Defold-Input
Defold-Input contains a number of different Lua modules and scripts to simplify input related operations such as gestures detection, user configurable key bindings, input state handling and dragging/clicking game objects.

* [Accelerometer](in/accelerometer.md)
* [Gesture](in/gesture.md)
* [Mapper](in/mapper.md)
* [Cursor](in/cursor.md)
* [State](in/state.md)
* [Button](in/button.md)
* [On screen virtual controls](in/onscreen.md)

## Setup
You can use the extension in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

https://github.com/britzl/defold-input/archive/master.zip

Or point to the ZIP file of a [specific release](https://github.com/britzl/defold-input/releases).

## Try HTML5 Demo
You can try an HTML5 demo of Defold-Input here: https://britzl.github.io/Defold-Input/

## Gooey
For a complete and easily skinnable UI system that supports buttons, checkboxes, input fields and lists please take a look at [Gooey](https://github.com/britzl/gooey).

## Gamepads
This project contains a gamepads definition file with the following gamepads configured:

* OSX
  * Wireless Controller
  * SteelSeries Stratus XL
  * PLAYSTATION(R)3 Controller
  * Controller
  * Xbox One Wired Controller
  * Generic USB Joystick
* Linux
  * Microsoft X-Box 360 pad
  * Sony PLAYSTATION(R)3 Controller
* Windows
  * XBox 360 Controller
  * cp

Help this list grow! Please submit pull requests for additional gamepads!
