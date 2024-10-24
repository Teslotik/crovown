package crovown.component.filter;

import crovown.interfaces.Renderable;
import crovown.backend.Backend.OutlineShader;
import crovown.ds.Rectangle;
import crovown.ds.Vector;
import crovown.types.Color;

@:build(crovown.Macro.component(false))
class OutlineFilter extends Filter {
    @:p public var color:Color = White;
    @:p public var thickness:Int = 2;
    @:p public var dx = 0.0;
    @:p public var dy = 0.0;

    public function setColor(color:Color) {}
    public function setThickness(thickness:Int) {}
    public function setOffset(dx:Float, dy:Float) {}

    var outline:OutlineShader = null;

    public static function build(crow:Crovown, component:OutlineFilter) {
        component.outline = crow.application.backend.shader(OutlineShader.label);
        return component;
    }

    override function onForward(canvas:Renderable, bounds:Rectangle) {
        canvas.push();
    }

    override function onBackward(canvas:Renderable, bounds:Rectangle) {
        // zone.load(bounds).grow(0, 0, radius * canvas.width / 100.0, radius * canvas.height / 100.0);

        outline.setColor(color);
        outline.setThickness(thickness);
        outline.setOffset(dx, dy);

        // canvas.buffer.pushScissors(Std.int(zone.x), Std.int(zone.y), Std.int(zone.w), Std.int(zone.h));
        // canvas.backbuffer.pushScissors(Std.int(zone.x), Std.int(zone.y), Std.int(zone.w), Std.int(zone.h));

        outline.setSurface(canvas.buffer);
        canvas.backbuffer.setShader(outline);
        canvas.backbuffer.drawSubRect(0, 0, canvas.width, canvas.height);
        canvas.backbuffer.flush();
        canvas.swap();

        // canvas.buffer.popScissors();
        // canvas.backbuffer.popScissors();

        canvas.pop(AlphaOver);
    }
}