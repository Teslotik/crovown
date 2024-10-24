package crovown.event;

import crovown.interfaces.Renderable;
import crovown.ds.Matrix;
import crovown.backend.Backend;
import crovown.backend.Backend.MixShader;
import crovown.component.Component;
import crovown.component.widget.Widget;
import crovown.backend.Backend.Surface;
import crovown.ds.Rectangle;
import crovown.types.Blend;

@:build(crovown.Macro.event())
class DrawWidgetEvent extends Event implements Renderable {
    // var w:Float;
    // var h:Float;
    // var stackSize = 1;
    var iBuffer = 0;
    
    public var buffers:Array<Surface> = null;
    // public var backbuffer1:Surface = null;
    // public var backbuffer2:Surface = null;
    // public var buffer(get, set):Surface;
    // function set_buffer(v:Surface) return buffers[stackSize - 1] = v;
    
    public var width(get, null):Float;
    function get_width() return width;
    
    public var height(get, null):Float;
    function get_height() return height;

    public var buffer(get, null):Surface;
    function get_buffer() return buffers[iBuffer];
    
    public var backbuffer(get, null):Surface = null;
    public function get_backbuffer() return backbuffer;

    public var mixer:MixShader = null;
    var zone = new Rectangle();

    public var surf:SurfaceShader = null;

    public function new(backend:Backend, maxWidth:Int, maxHeight:Int) {
        super();
        this.width = maxWidth;
        this.height = maxHeight;

        // Up to 10 effects
        buffers = [for (i in 0...10) backend.surface(maxWidth, maxHeight)];
        // backbuffer1 = backend.surface(maxWidth, maxHeight);
        // backbuffer2 = backend.surface(maxWidth, maxHeight);
        backbuffer = backend.surface(maxWidth, maxHeight);
        mixer = backend.shader(MixShader.label);
        surf = backend.shader(SurfaceShader.label);
    }

    public function push() {
        if (iBuffer + 1 >= buffers.length) throw "Too many effects";
        iBuffer++;
        buffer.clear(Transparent);
        backbuffer.clear(Transparent);
        return buffer;
    }

    public function pop(?blend:Blend, ?factor:Float) {
        if (iBuffer <= 0) throw  "No more buffers";
        
        if (blend == null) {
            // backbuffer.clear(Transparent);
            buffer.clear(Transparent);
            return buffers[--iBuffer];
        }

        var top = buffers[iBuffer];
        var current = buffers[--iBuffer];
        mixer.setSource(current);
        mixer.setDestination(top);
        mixer.setBlend(blend ?? AlphaOver);
        mixer.setFactor(factor ?? 1.0);
        // backbuffer.clear(Transparent);
        backbuffer.setShader(mixer);
        backbuffer.drawSubRect(0, 0, width, height);
        backbuffer.flush();
        return swap();
        
        // swap();
        // backbuffer.clear(Transparent);
        // return buffer;

        // surf.setSurface(buffers[iBuffer--]);
        // buffer.setShader(surf);
        // buffer.drawSubRect(0, 0, width, height);
        // buffer.flush();
        // return buffer;
    }

    public function swap() {
        var tmp = backbuffer;
        backbuffer = buffer;
        buffers[iBuffer] = tmp;
        backbuffer.clear(Transparent);
        return buffer;
    }

    // public function swap2() {
    //     var tmp = backbuffer;
    //     backbuffer = buffer;
    //     buffers[iBuffer] = tmp;
    //     backbuffer.clear(Transparent);
    //     return buffer;
    // }
    
    public function clear() {
        iBuffer = 0;
    }

    public function setCamera(w:Int, h:Int) {
        this.width = w;
        this.height = h;
        
        for (buffer in buffers) {
            buffer.clear(Transparent);
            buffer.clearTransform();
            buffer.viewport(0, 0, w, h);
            buffer.pushTransform(Matrix.Orthogonal(0, w, h, 0, 0.1, 100));
            buffer.pushTransform(Matrix.Translation(0, 0, -50));
        }

        backbuffer.clear(Transparent);
        backbuffer.clearTransform();
        backbuffer.viewport(0, 0, w, h);
        backbuffer.pushTransform(Matrix.Orthogonal(0, w, h, 0, 0.1, 100));
        backbuffer.pushTransform(Matrix.Translation(0, 0, -50));
        
        // backbuffer1.clear(Transparent);
        // backbuffer1.clearTransform();
        // backbuffer1.viewport(0, 0, w, h);
        // backbuffer1.pushTransform(Matrix.Orthogonal(0, w, h, 0, 0.1, 100));
        // backbuffer1.pushTransform(Matrix.Translation(0, 0, -50));
        
        // backbuffer2.clear(Transparent);
        // backbuffer2.clearTransform();
        // backbuffer2.viewport(0, 0, w, h);
        // backbuffer2.pushTransform(Matrix.Orthogonal(0, w, h, 0, 0.1, 100));
        // backbuffer2.pushTransform(Matrix.Translation(0, 0, -50));
    }

    override function onForward(component:Component) {
        isSkip = false;
        var widget = cast(component, Widget);
        // @todo
        widget.buildTransform();
        if (widget.isEnabled) {
            var bounds = widget.getAABB();
            if (widget.clip) {
                buffer.pushScissors(Std.int(bounds.x), Std.int(bounds.y), Std.int(bounds.w), Std.int(bounds.h));
            }
            // @todo
            // Widgets outside window will not de drawn
            // @todo перед clip?
            if (widget.filter != null) {
                widget.filter.onForward(this, bounds);
            }
            if ((bounds.right < 0 || bounds.left > width || bounds.bottom < 0 || bounds.top > height) && widget.isHideable) {
                isSkip = true;
            }
        } else {
            isCancelled = true;
        }
    }

    override function onBackward(component:Component) {
        var widget = cast(component, Widget);
        if (!widget.isEnabled) return;
        
        if (widget.filter != null) {
            // backbuffer1.clear(Transparent);
            var bounds = widget.getAABB();
            // widget.filter.draw(buffer, backbuffer1, zone.set(bounds.x, bounds.y, bounds.w, bounds.h));

            // stackSize--;

            // mixer.setSource(buffer);
            // mixer.setDestination(backbuffer1);
            // mixer.setFactor(1);
            // mixer.setBlend(AlphaOver);
            // backbuffer2.clear(Transparent);
            // backbuffer2.setShader(mixer);
            // backbuffer2.drawSubRect(0, 0, w, h);
            // backbuffer2.flush();

            // swap
            // var tmp = backbuffer2;
            // backbuffer2 = buffer;
            // buffer = tmp;

            widget.filter.onBackward(this, bounds);
        }

        if (widget.clip) buffer.popScissors();
    }
}