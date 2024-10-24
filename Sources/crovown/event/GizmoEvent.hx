package crovown.event;

import crovown.ds.Matrix;
import crovown.backend.Backend;
import crovown.backend.Backend.Input;
import crovown.backend.Backend.Surface;

@:build(crovown.Macro.event())
class GizmoEvent extends Event {
    public var crow:Crovown = null;
    public var surface:Surface = null;
    public var input:Input = null;  // @todo
    var w:Float;
    var h:Float;

    public function new(backend:Backend, maxWidth:Int, maxHeight:Int) {
        super();
        this.w = maxWidth;
        this.h = maxHeight;
        this.surface = backend.surface(maxWidth, maxHeight);
    }

    public function setCamera(w:Int, h:Int) {
        this.w = w;
        this.h = h;
        
        surface.clear(Transparent);
        surface.clearTransform();
        surface.viewport(0, 0, w, h);
        surface.pushTransform(Matrix.Orthogonal(0, w, h, 0, 0.1, 100));
        surface.pushTransform(Matrix.Translation(0, 0, -50));
    }
}