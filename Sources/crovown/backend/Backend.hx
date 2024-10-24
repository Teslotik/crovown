package crovown.backend;

import haxe.io.Bytes;
import crovown.ds.Image;
import crovown.types.Action;
import crovown.ds.GradientPoint;
import crovown.algorithm.Geometry;
import crovown.ds.Rectangle;
import crovown.types.Blend;
import crovown.types.Color;
import crovown.ds.Matrix;
// import crovown.backend.LimeBackend.LimeContext;

using Lambda;

// @todo ResourceLoader? - или фабрики в Backend будет достаточно?
// реестр ресурсов

/*
attributes:
- local position
- color
- uv
- normal
- tangent
- island index
*/

// typedef ContextT = crovown.backend.LimeBackend.LimeContext;
// #if lime
// #end

class Backend {
    // --- Factory/Registry ---
    
    public function screenSurface(w:Int, h:Int):Surface {
        return null;
    }

    public function surface(w:Int, h:Int):Surface {
        // throw "surface is NotImplemented";
        return null;
    }

    public function loadSurface(path:String):Surface {
        // throw "surface is NotImplemented";
        return null;
    }

    public function loadImage(image:Image):Surface {
        // throw "surface is NotImplemented";
        return null;
    }

    public function shader<S:Shader>(label:String):S {
        // throw "mouse is NotImplemented";
        return null;
    }

    public function font(label:String, size:Int = 16):Font {
        // throw "font is NotImplemented";
        return null;
    }

    public function mouse(index:Int):Mouse {
        // throw "mouse is NotImplemented";
        return null;
    }

    public function keyboard(index:Int):Keyboard {
        // throw "keyboard is NotImplemented";
        return null;
    }

    public function touchscreen(index:Int):Touchscreen {
        // throw "touchscreen is NotImplemented";
        return null;
    }

    public function gamepad(index:Int):Gamepad {
        // throw "gamepad is NotImplemented";
        return null;
    }

    public function input(id:Int):Input {
        return null;
    }
}

class Surface {
    public var coloredShader:ColoredShader = null;

    public function new(coloredShader:ColoredShader) {
        this.coloredShader = coloredShader;
    }

    // @todo
    // public function createCache():Cache { return null; }
    // public function setCache(cache:Cache) {}

    public function destroy() {}
    public function save():Bytes { return null; }
    public function getWidth():Int { return 0; }
    public function getHeight():Int { return 0; }
    // public function getActualWidth():Int { return 0; }
    // public function getActualHeight():Int { return 0; }
    
    // public function resize(w:Int, h:Int) {}   // @todo rename
    public function viewport(x:Int, y:Int, w:Int, h:Int) {} // @todo удалить @todo rename camera
    // public function camera(x:Int, y:Int, w:Int, h:Int) {}   // @todo rename
    public function setDepth(z:Float) {}
    public function getDepth():Float { return 0.0; }
    
    public function setColor(?color:Color) {}
    public function setShader(shader:Shader) {}  // color, gradient, image/surface (blend), shaders (blur, outline), font
    public function setFont(font:Font) {}

    public function getTransform():Matrix { return null; }
    public function clearTransform() {}
    public function pushTransform(transform:Matrix) {}
    public function popTransform() {}

    public function pushScissors(x:Int, y:Int, w:Int, h:Int) {}
    public function popScissors() {}
    public function clearScissors() {}

    public function clear(color:Color) {}
    public function fill() {}
    public function flush() {}
    public function drawPixel(x:Float, y:Float) {}
    public function drawTri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float) {}
    public function drawRect(x:Float, y:Float, w:Float, h:Float) {}
    // @todo передавать координаты и размеры прямоугольника?
    public function drawSubRect(x:Float, y:Float, w:Float, h:Float) {}
    public function drawTile(x:Float, y:Float, w:Float, h:Float, dx:Float, dy:Float, dw:Float, dh:Float) {}
    public function drawLine(x1:Float, y1:Float, x2:Float, y2:Float, thickness:Float) {}
    public function drawString(string:String, x:Float, y:Float) {}
    public function drawShape(points:Array<Float>) {}
    public function drawConvexPolygon(points:Array<Float>) {}
    public function drawPolygon(points:Array<Float>) {}
    public function drawMesh(points:Array<Float>, ?indices:Array<Int>) {}
}



class Shader {
    @:deprecated
    public function getBounds():Rectangle { return null; }
    public function apply(surface:Surface) {}
}

class ColoredShader extends Shader {
    public static final label = "ColoredShader";
    public function setColor(color:Color) {}
}

class SurfaceShader extends Shader {
    public static final label = "SurfaceShader";
    public function setSurface(surface:Surface) {}
    public function setTile(x:Float, y:Float, w:Float, h:Float) {}
}

class GradientShader extends Shader {
    public static final label = "GradientShader";
    public static final buffer = 16;
    public function setPoints(points:Array<GradientPoint>) {}
    public function setStart(x:Float, y:Float, z = 0.0) {}
    public function setEnd(x:Float, y:Float, z = 0.0) {}
}

class MixShader extends Shader {
    public static final label = "MixShader";
    public function setSource(surface:Surface) {}
    public function setDestination(surface:Surface) {}
    public function setBlend(blend:Blend) {}
    public function setFactor(f:Float) {}
    public function setAlpha(a:Bool) {}
}

class MaskShader extends Shader {
    public static final label = "MaskShader";
    public function setSurface(s:Surface) {}
    public function setMask(m:Surface) {}
    public function setThreshold(t:Float) {}
}

class AdjustColorShader extends Shader {
    public static final label = "AdjustShader";
    public function setSurface(surface:Surface) {}
}

class BlurDirectionalShader extends Shader {
    public static final label = "BlurDirectionalShader";
    public function setSurface(surface:Surface) {}
    public function setColor(c:Color) {}
    public function setClip(c:Bool) {}
    public function setSamples(s:Int) {}
    public function setDirection(dx:Float, dy:Float) {}
    public function setRadius(r:Float) {}
}

class ShadowShader extends Shader {
    public static final label = "ShadowShader";
    public function setInner(inner:Bool) {}
    public function setSpread(spread:Int) {}
    public function setBlur(blur:Int) {}
    public function setOffset(dx:Float, dy:Float) {}
    public function setColor(color:Color) {}
}

class OutlineShader extends Shader {
    public static final label = "OutlineShader";
    public function setSurface(surface:Surface) {}
    public function setColor(color:Color) {}
    public function setThickness(thickness:Int) {}
    public function setOffset(dx:Float, dy:Float) {}
}

class SdfShader extends Shader {
    public static final label = "SdfShader";
    public function setSurface(surface:Surface) {}
    public function setColor(color:Color) {}
    public function setThreshold(threshold:Float) {}
    public function setContrast(contrast:Float) {}
}

// glow


// -------------------- Input --------------------
class Input {
    public var down = new List<Action>();
    public var prev = new List<Action>();

    public function new() {
        
    }

    public function update() {
        prev.clear();
        down.iter(i -> prev.add(i));
    }

    public function press(action:Action) {
        down.map(a -> if (a.equals(action)) down.remove(a));
        down.add(action);
        return this;
    }

    public function release(action:Action) {
        down.map(a -> if (a.equals(action)) down.remove(a));
        return this;
    }

    public function isDown(action:Action) {
        // @todo для isDown и для wasDown
        // switch (action) {
        //     case Axis(id, v): return down.exists(a -> switch (a));
        //     default: down.exists(a -> a.equals(action));
        // }
        return down.exists(a -> a.equals(action));
    }

    public function wasDown(action:Action) {
        return prev.exists(a -> a.equals(action));
    }

    public function isPressed(action:Action) {
        return isDown(action) && !wasDown(action);
    }

    public function isReleased(action:Action) {
        return !isDown(action) && wasDown(action);
    }

    // @todo принимает в качастве аргумент action и взозвращает последний из них
    public function justPressed() {
        var last = down.last();
        if (last == null) return null;
        if (wasDown(last)) return null;
        return last;
    }

    // @todo см. выше
    public function justReleased() {
        var last = prev.last();
        if (last == null) return null;
        if (isDown(last)) return null;
        return last;
    }

    // @todo
    public function isHolding(action:Action) {
        
    }

    public function isCombination(actions:Array<Action>, order = true) {
        if (order) {
            var i = 0;
            down.iter(item -> if (item.equals(actions[i])) i++);
            return i == actions.length && isPressed(actions[actions.length - 1]);
        } else {
            return actions.foreach(a -> isDown(a)) && actions.exists(a -> isPressed(a));
        }
    }
}







class Mouse {
    public var isLeftDown(get, default):Bool = false;
    public var isRightDown(get, default):Bool = false;
    public var isMiddleDown(get, default):Bool = false;
    public var x(get, default):Float = 0;
    public var y(get, default):Float = 0;
    public var wheelDeltaX(get, default):Float = 0;
    public var wheelDeltaY(get, default):Float = 0;

    public function get_isLeftDown():Bool { return isLeftDown; }
    public function get_isRightDown():Bool { return isRightDown; }
    public function get_isMiddleDown():Bool { return isMiddleDown; }
    public function get_x():Float { return x; }
    public function get_y():Float { return y; }
    public function get_wheelDeltaX():Float { return wheelDeltaX; }
    public function get_wheelDeltaY():Float { return wheelDeltaY; }

    // public function getDx():Float {
    //     // throw "NotImplemented";
    //     return 0;
    // }

    // public function getDy():Float {
    //     // throw "NotImplemented";
    //     return 0;
    // }
}

// enum abstract KeyCode(String) from String to String {
//     var Backspace;
// }

class Keyboard {
    public function isDown(key:String) {
        return false;
    }

    public function getDown():List<String> {
        // throw "NotImplemented";
        return null;
    }
}

class Touchscreen {

}

class Gamepad {

}

// -------------------- Resources --------------------

typedef Glyph = {
    char:String,
    x:Float,
    y:Float,
    dx:Float,
    dy:Float,
    w:Float,
    h:Float,
}

// @todo remove
class Font {
    public static var collection = new Map<String, Font>();

    var data:format.fnt.Data = null;
    public var chars = new Map<String, Glyph>();
    public var size:Int = 16;
    public var isBold:Bool = false;
    public var isItalic:Bool = false;
    public var letterSpacing:Array<Int> = [0, 0];
    public var wordSpacing = 16;
    public var w = 128;
    public var h = 128;
    public var texture:Surface = null;
    public var align = 1;
    public var scale = 1.0;   // @todo property

    public function new(label:String) {
        collection.set(label, this);

        // var path = "/home/sergei/Temp/arial.fnt";

        // var source = crovown.Macro.getContent("/home/sergei/Temp/arial.fnt");
        // var source = "";
    }

    public function loadFnt(source:String) {
        var reader = new format.fnt.Reader();
        data = reader.readBmFont(source);

        size = data.info.size;
        isBold = data.info.bold;
        w = data.common.scaleW;
        h = data.common.scaleH;
        letterSpacing = data.info.spacing;

        for (char in data.chars) {
            var c = String.fromCharCode(char.id);
            chars.set(c, {
                char: c,
                x: char.x,
                y: char.y,
                dx: char.xoffset,
                dy: char.yoffset,
                w: char.width,
                h: char.height
            });
        }
        return this;
    }

    public function getWidth(string:String, ?len:Int):Float {
        var total = 0.0;
        // var spaces = 0;
        if (len == null) {
            len = string.length;
        } else if (len > string.length) {
            len = string.length;
        }
        for (i in 0...len) {
            var char = string.charAt(i);
            if (!chars.exists(char) || char == " ") {
                // spaces++;
                total += wordSpacing * scale;
            } else {
                total += chars[char].w * scale + chars[char].dx * scale + letterSpacing[0] * scale;
            }
        }
        // return total + wordSpacing * scale * spaces + Geometry.space(letterSpacing[0], len - spaces);
        // return total + wordSpacing * scale * spaces;
        return total;
    }

    public function getHeight(string:String):Float {
        return size * scale;
    }

    public function getPosition(string:String, width:Float) {
        var total = 0.0;
        for (i in 0...string.length) {
            var char = string.charAt(i);
            var w = 0.0;
            if (!chars.exists(char) || char == " ") {
                w = wordSpacing * scale;
            } else {
                w = chars[char].w * scale + chars[char].dx * scale + letterSpacing[0] * scale;
            }
            if (total + w / 2 > width) return i;
            if (total > width) return i + 1;
            total += w;
        }
        return string.length;
    }

    public function setSize(v:Float) {
        scale = v / size;
    }
}

// -------------------- Shaders --------------------

