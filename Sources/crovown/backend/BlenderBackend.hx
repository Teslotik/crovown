package crovown.backend;

import crovown.backend.Backend.Surface;
import crovown.backend.Backend.Font;

class BlenderBackend {
    public static function draw(self:Dynamic, context:Context) {
        trace("a");
    }
}

class BlenderFont extends Font {


    public function createTexture() {
        
    }
}

class BlenderSurface extends Surface {
    
}

// ---------------------- API ----------------------

@:pythonImport("bpy") extern class BlenderApi {
    static var context:Context;
}

@:pythonImport("bpy.context") extern class Context {
    var active_object:Object;
}

// @:pythonImport("bpy.context") @:native("context") extern class Context {
//     static var active_object:Object;
// }

@:pythonImport("bpy.tyeps.Object") extern class Object {
    function select_set(state:Bool):Void;
}




@:pythonImport("blf") extern class Blf {
    static function color(fontid:Int, r:Float, g:Float, b:Float, a:Float):Void;
    static function dimensions(fontid:Int, text:String):Array<Float>;
    static function draw(fontid:Int, text:String):Void;
    static function load(filepath:String):Int;
    static function position(fontid:Int, x:Int, y:Int, z:Int):Void;
    static function size(fontid:Int, size:Float):Int;
}

@:pythonImport("bgl") extern class Bgl {
    
}