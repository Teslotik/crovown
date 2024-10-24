package crovown.event;

import crovown.ds.Vector;
import crovown.backend.Backend.Mouse;
import crovown.backend.Backend.Keyboard;
import crovown.backend.Backend.Touchscreen;
import crovown.backend.Backend.Gamepad;
import crovown.backend.Backend.Input;

@:build(crovown.Macro.event())
class InputEvent extends Event {
    public var mouse:Mouse = null;
    public var keyboard:Keyboard = null;
    public var touchscreen:Touchscreen = null;
    public var gamepad:Gamepad = null;
    public var input:Input = null;
    public var position = new Vector(); // local position (transformed mouse)
}