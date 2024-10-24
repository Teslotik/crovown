package crovown.component.filter;

import crovown.backend.Backend.MaskShader;
import crovown.interfaces.Renderable;
import crovown.backend.Backend.BlurDirectionalShader;
import crovown.backend.Backend.Surface;
import crovown.ds.Rectangle;
import crovown.ds.Vector;
import crovown.types.Color;

@:build(crovown.Macro.component(false))
class BlurFilter extends Filter {
    @:p public var color:Color = White;
    @:p public var samples:Int = 25;
    @:p public var radius:Float = 8.0;
    @:p public var clip:Bool = false;
    @:p public var background:Bool = false;

    var blur:BlurDirectionalShader = null;
    var mask:MaskShader = null;

    public static function build(crow:Crovown, component:BlurFilter) {
        component.blur = crow.application.backend.shader(BlurDirectionalShader.label);
        component.mask = crow.application.backend.shader(MaskShader.label);
        return component;
    }

    override function onForward(canvas:Renderable, bounds:Rectangle) {
        canvas.push();
    }

    override function onBackward(canvas:Renderable, bounds:Rectangle) {
        zone.load(bounds).grow(0, 0, radius * canvas.width / 100.0, radius * canvas.height / 100.0);

        blur.setColor(color);
        blur.setRadius(radius);
        blur.setSamples(samples);

        canvas.buffer.pushScissors(Std.int(zone.x), Std.int(zone.y), Std.int(zone.w), Std.int(zone.h));
        canvas.backbuffer.pushScissors(Std.int(zone.x), Std.int(zone.y), Std.int(zone.w), Std.int(zone.h));

        blur.setSurface(canvas.buffer);
        blur.setClip(clip);
        blur.setDirection(1, 0);
        canvas.backbuffer.setShader(blur);
        canvas.backbuffer.drawSubRect(0, 0, canvas.width, canvas.height);
        canvas.backbuffer.flush();
        canvas.swap();

        // canvas.backbuffer.clear(Transparent);
        blur.setDirection(0, 1);
        blur.setSurface(canvas.buffer);
        canvas.backbuffer.setShader(blur);
        canvas.backbuffer.drawSubRect(0, 0, canvas.width, canvas.height);
        canvas.backbuffer.flush();
        canvas.swap();

        canvas.buffer.popScissors();
        canvas.backbuffer.popScissors();

        canvas.pop(AlphaOver);

        if (background) {
            /*
            - фигуры рисуются в новый слой маски
            - маска сохраняется
            - фон копируется в новый слой и размытие рисуется в него и backbuffer
            - фон маскируется маской
            - фон смешивается с предыдущим слоем
            */
        }
    }
}