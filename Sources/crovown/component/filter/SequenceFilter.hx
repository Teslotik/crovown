package crovown.component.filter;

import crovown.backend.Backend.SurfaceShader;
import crovown.ds.Rectangle;
import crovown.backend.Backend.Surface;

@:build(crovown.Macro.component(false))
class SequenceFilter extends Filter {
    var mixer:SurfaceShader = null;

    public static function build(crow:Crovown, component:SequenceFilter) {
        return component;
    }

    /*
    override public function draw(src:Surface, dst:Surface, zone:Rectangle) {
        mixer ??= crow.application.backend.shader(SurfaceShader.label);
        var switched = true;
        var children:Array<Filter> = getChildren();
        var tmp:Surface = null;
        for (child in children) {
            child.draw(src, dst, zone);
            tmp = dst;
            dst = src;
            src = tmp;
            switched = !switched;
        }
        if (tmp != null && switched) {
            mixer.setSurface(src);
            dst.setShader(mixer);
            // dst.drawSubRect(0, 0, crow.application.w, crow.application.h, 0, 0, crow.application.w / crow.application.displayWidth, crow.application.h / crow.application.displayHeight);
            dst.drawSubRect(0, 0, crow.application.w, crow.application.h);
            dst.flush();
        }
    }
    */
}