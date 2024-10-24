package crovown.interfaces;

import crovown.backend.Backend.Surface;
import crovown.types.Blend;

interface Renderable {
    public var width(get, null):Float;
    public var height(get, null):Float;
    public var buffer(get, null):Surface;
    public var backbuffer(get, null):Surface;
    // public var backbuffer2(get, null):Surface;

    public function push():Null<Surface>;
    public function pop(?blend:Blend, ?factor:Float):Null<Surface>;
    public function swap():Surface;
    // public function swap2():Surface;
    public function clear():Void;
}