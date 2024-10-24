package crovown.component.widget;

import crovown.event.ValidateEvent;
import crovown.event.GizmoEvent;
import crovown.event.SizeEvent;
import crovown.event.LayoutEvent;
import crovown.event.PositionEvent;
import crovown.event.DrawWidgetEvent;
import crovown.event.InputEvent;
import crovown.algorithm.MathUtils;
import crovown.backend.Backend.ColoredShader;
import crovown.backend.Backend.GradientShader;
import crovown.backend.Backend.Mouse;
import crovown.backend.Backend.Surface;
import crovown.backend.Backend.SurfaceShader;
import crovown.component.filter.Filter;
import crovown.ds.Area;
import crovown.ds.Matrix;
import crovown.ds.Vector;
import crovown.types.Anchor;
import crovown.types.BorderRadius;
import crovown.types.BorderWidth;
import crovown.types.Fill;
import crovown.types.Kind;
import crovown.types.Resizing;

using crovown.algorithm.Shape;

@:build(crovown.Macro.component(false))
class Widget extends Component {
    public var colorId = 0;

    @:p public var color:crovown.types.Fill = null;
    @:p public var borderColor:crovown.types.Fill = null;
    @:p public var borderWidth:Null<BorderWidth> = null;
    @:p public var borderRadius:Null<BorderRadius> = null;
    @:p public var borderPosition:Int = 1;
    
    // Rectangle
    public var x:Null<Float> = null;
    public var y:Null<Float> = null;
    public var w(default, set):Null<Float> = null;
    function set_w(v:Null<Float>) return w = MathUtils.clamp(v, minW, maxW);
    public var h(default, set):Null<Float> = null;
    function set_h(v:Null<Float>) return h = MathUtils.clamp(v, minH, maxH);
    
    // Constraints
    @:p public var minW:Null<Float> = 0.0;
    @:p public var minH:Null<Float> = 0.0;
    @:p public var maxW:Null<Float> = null;
    @:p public var maxH:Null<Float> = null;

    // Canvas
    @:p public var posX(default, set):Null<Float> = null;
    function set_posX(v:Null<Float>) return x = posX = v;
    @:p public var posY(default, set):Null<Float> = null;
    function set_posY(v:Null<Float>) return y = posY = v;
    
    @:p public var pivotX:Float = 0.0;
    @:p public var pivotY:Float = 0.0;

    @:p public var transform:Matrix = Matrix.Identity();
    public var local = Matrix.Identity();
    public var world = Matrix.Identity();
    public var parentInverse = Matrix.Identity();

    // Resizing
    @:p public var horizontal(default, set):Resizing = Fill;
    function set_horizontal(v:Resizing) {
        switch (v) {
            case Fixed(v): w = v;
            case _: null;
        }
        return horizontal = v;
    }
    @:p public var vertical(default, set):Resizing = Fill;
    function set_vertical(v:Resizing) {
        switch (v) {
            case Fixed(v): h = v;
            case _: null;
        }
        return vertical = v;
    }

    // Anchors
    @:p public var left:Null<Anchor> = null;
    @:p public var top:Null<Anchor> = null;
    @:p public var right:Null<Anchor> = null;
    @:p public var bottom:Null<Anchor> = null;
    @:p public var anchors(null, set):Null<Anchor>;  // @todo never instead of null
    function set_anchors(v:Anchor) {
        return left = top = right = bottom = v;
    }
    // Align
    @:p public var align:Float = 0;

    // Flags
    @:p public var clip:Bool = false;
    @:p public var drag:Widget->Area = null;
    @:p public var isHideable:Bool = true;

    // Filters
    @:p public var filter:Filter = null;

    // Callbacks
    @:p public var onInput:InputEvent->Bool = null; // @todo заменить на событие
    @:p public var onDraw:Widget->StageGui->Void = null;

    var aabb = new Area();
    // Support vectors
    var ul = new Vector();
    var ur = new Vector();
    var bl = new Vector();
    var br = new Vector();
    
    public var colored:ColoredShader = null;
    public var gradient:GradientShader = null;
    public var surface:SurfaceShader = null;

    public function new() {
        super();
        kind = Kind.Widget;
        // drag = aabb;
        // colorId = (label == "" ? MathUtils.hashInt(id + salt) : MathUtils.hashString(label + salt)) | 0xFF000000;
        colorId = (label == "" ? MathUtils.hashInt(id) : MathUtils.hashString(label)) | 0xFF000000;
    }

    public static function build(crow:Crovown, component:Widget) {
        return component;
    }

    // static function setFill(surface2D:Surface2D, color:Fill, x:Float, y:Float) {
    //     // trace(x, y);
    //     switch (color) {
    //         case LinearGradient(sx, sy, ex, ey, points):
    //             surface2D.setFill(LinearGradient(x + sx, y + sy, x + ex, y + ey, points));
    //         case Image(sx, sy, ex, ey, image):
    //             surface2D.setFill(Image(x + sx, y + sy, x + ex, y + ey, image));
    //         case _:
    //             surface2D.setFill(color);
    //     }
    // }

    static function makeFill(surface2D:Surface, color:crovown.types.Fill, x:Float, y:Float, w:Float, h:Float) {
        // trace(x, y);
        // switch (color) {
        //     case LinearGradient(sx, sy, ex, ey, points):
        //         surface2D.setFill(LinearGradient(x + sx, y + sy, x + ex, y + ey, points));
        //         // case Image(sx, sy, ex, ey, image):
        //     case Image(sx, sy, ex, ey, image, cover):
        //         var imageW = ex - sx;
        //         var imageH = ey - sy;
        //         // var cover:Cover = Stretch;
        //         switch (cover) {
        //             case Stretch | null: surface2D.setFill(Image(x + sx, y + sy, x + w, y + h, image));
        //             case Keep: {
        //                 // if (imageW > imageH) {
        //                 //     var keepH = imageH * w / imageW;
        //                 //     surface2D.setFill(Image(x + sx, y + sy + h / 2 - keepH / 2, x + w, y + h / 2 + keepH / 2, image));
        //                 // } else {
        //                 //     // var keepW = imageW * h / imageH;
        //                 //     // var keepW = imageH / imageW * w;
        //                 //     // surface2D.setFill(Image(x + sx + w / 2 - keepW / 2, y + sy, x + w / 2 + keepW / 2, y + h, image));
        //                 //     // surface2D.setFill(Image(x + sx + w / 2 - keepW / 2, y + sy, x + keepW, y + h, image));
        //                 //     // var keepW = 200;
        //                 //     // var keepW = imageW * h / imageH;

        //                 //     // h - 1
        //                 //     // w - imageH / imageW

        //                 //     // var keepW = (imageH / imageW) * (h / w);


        //                 //     /*
        //                 //     imageW = 100
        //                 //     imageH = 100

        //                 //     ratio = 100 / 100 = 1
        //                 //     keepW = ratio * h;

        //                 //     */

        //                 //     imageW = 1600;
        //                 //     imageH = 900;

        //                 //     var aspect = imageH / imageW;
        //                 //     var keepW = w;
        //                 //     var keepH = aspect * w;

        //                 //     var keepW = imageW / imageH * h;

        //                 //     // surface2D.setFill(Image(x + w / 2 - keepW / 2, y, x + keepW, y + h, image));
        //                 //     surface2D.setFill(Image(x, y, x + w, y + aspect * w, image));
        //                 // }

        //                 // Cover
        //                 // var keepW = imageW > imageH ? imageH / imageW * h : w;
        //                 // var keepH = imageW <= imageH ? imageW / imageH * w : h;
        //                 // surface2D.setFill(Image(x, y, x + keepW, y + keepH, image));

        //                 // var keepW = true ? imageH / imageW * h : w;
        //                 // var keepH = false ? imageW / imageH * w : h;

        //                 /*
        //                 w = 456
        //                 h = 202
        //                 r1 = 456 / 202 = 2.26

        //                 imageW = 1600;
        //                 imageH = 900;
        //                 r2 = 1600 / 900 = 1.7


        //                 if (h * r2 > w) {
        //                     imageW = w;
        //                     imageH = w / r2;
        //                 }


        //                 // if (h * ratio > w) {



        //                 // if (imageH * r > w) {
        //                 //     imageW = w;
        //                 //     imageH = w / r;
        //                 // }




        //                 var ratio = w / h;
        //                 var newW = imageW > imageH: 
        //                 var newW = imageW * ratio;

        //                 if (w / h * imageH > w) {

        //                 }


        //                 if (w / ratio < container.h) {
        //                     h = w / ratio;
        //                 } else {
        //                     w = h * ratio;
        //                 }


        //                 */
        //                 // trace("w, h", imageW, imageH);

        //                 var ratio = imageW / imageH;
        //                 var keepW = w / ratio > h ? h * ratio : w;
        //                 var keepH = w / ratio <= h ? w / ratio : h;
        //                 surface2D.setFill(Image(
        //                     x + sx + w / 2 - keepW / 2,
        //                     y + sy + h / 2 - keepH / 2,
        //                     x + sx + w / 2 + keepW / 2,
        //                     y + sy + h / 2 + keepH / 2,
        //                     image
        //                 ));
        //             }
        //             // case Cover: {
        //             //     // @todo не работает, передалать
        //             //     // var keepW = imageW > imageH ? imageH / imageW * h : w;
        //             //     // var keepH = imageW <= imageH ? imageW / imageH * w : h;
        //             //     // surface2D.setFill(Image(x, y, x + keepW, y + keepH, image));
        //             // }
        //         }
        //     case _:
        //         surface2D.setFill(color);
        // }
    }



    function setupFill(surface:Surface, color:crovown.types.Fill, salt = 0) {
        switch (color) {
            case Color(v):
                colored ??= crow.application.backend.shader(ColoredShader.label);
                colored.setColor(v);
                surface.setShader(colored);
            case LinearGradient(sx, sy, ex, ey, points):
                gradient ??= crow.application.backend.shader(GradientShader.label);
                gradient.setStart(sx, sy);
                gradient.setEnd(ex, ey);
                gradient.setPoints(points);
                surface.setShader(gradient);
            case Image(width, height, image, cover):
                this.surface ??= crow.application.backend.shader(SurfaceShader.label);
                this.surface.setTile(0, 0, 1, 1);
                switch (cover) {
                    // @todo
                    case Stretch | null:
                        this.surface.setSurface(image);
                    case Keep:
                        var ratio = height / width;
                        // if (width / ratio < this.h) {
                        //     height = width / ratio;
                        // } else {
                        //     width = height * ratio;
                        // }

                        // var scale = if (width / ratio < this.h) {
                        //     width / ratio;
                        // } else {
                        //     height * ratio;
                        // }

                        // var scale = MathUtils.lerp();
                        // var scale = width / w;
                        // var scale = w / width;
                        // var scale = h / height;
                        // trace(h, height, h / height, height / h);
                        // var scale = MathUtils.lerp(1, 0, 0, height, h);
                        // var scale = 1;
                        // var scale = w / h;
                        // var scale = h / w;
                        
                        // var scale = (width / height) * (h / w);


                        //
                        // var scale = (width / height) * (h / w);
                        // if (scale < 1) {
                        //     // this.surface.setTile(0, 0, 1, scale);
                        //     this.surface.setTile(0, 0, 1, 1);
                        // } else {
                        //     this.surface.setTile(0, 0, 1 / scale, 1);
                        //     // this.surface.setTile(0, 0, 1, 1);
                        //     // this.surface.setTile(1 / (-scale / 2), 0, 1 / (scale / 2), 1);
                        //     // this.surface.setTile((-scale / 2), 0, (scale / 2), 1);
                        //     // this.surface.setTile((-scale / 2), 0, 1, 1);
                        //     // this.surface.setTile((-scale / 2), 0, 1 / scale, 1);
                        //     // this.surface.setTile(MathUtils.lerp(scale, 0, 1, 1, 0), 0, 1 / scale, 1);
                        //     // this.surface.setTile(0.1, 0, 1 / scale, 1);
                        // }

                        // if (FitWidth)
                        // else if (FitHeight)
                        // if (StretchKeepAspect)
                        // var scale = (width / height) * (h / w);
                        // this.surface.setTile(0, 0, 1, scale);

                        // w / h


                        /*
                        tw = 1
                        wh = x

                        tw * x = 

                        width * f = w
                        f = w / width

                        f = (w / width) * (h / height)
                        */

                        // var f = w / width;
                        // var f = (w / width) * (h / w);
                        // var f = (w / width) * (w / h);
                        // var f = (w / width) * (w / height);
                        // var f = (w / width) * (height / w);
                        // var f = (w / width) * (height / width);
                        // var f = (w / width) * (width / height);
                        // var f = (w / width) * (1 / height);
                        // var f = (w / width) * height;
                        // var f = h / ((w / width) * height);     //
                        // this.surface.setTile(0, 0, 1, f);

                        // this.surface.setTile(0, 0.5 - f / 2, 1, f);
                        // this.surface.setTile(0, 0, 1, f);

                        // trace(w, width, w / width, width / w);
                        
                        // width * x = w
                        // x = w / width

                        // if ()
                        
                        // var keepW = w / ratio > h ? h * ratio : w;
                        // var keepH = w / ratio <= h ? w / ratio : h;
                        // var scale = 


                        // this.surface.setTile(0, 0, 1, scale);

                        // @todo позиционирование по центру, но не в setTile?
                        var f = h / ((w / width) * height);
                        if (f > 1) {
                            this.surface.setTile(0, 0, 1, f);
                        } else {
                            var f = w / ((h / height) * width);
                            this.surface.setTile(0, 0, f, 1);
                        }
                        this.surface.setSurface(image);
                    case Covered:
                        // @todo позиционирование по центру, но не в setTile?
                        var f = h / ((w / width) * height);
                        if (f < 1) {
                            this.surface.setTile(0, 0, 1, f);
                        } else {
                            var f = w / ((h / height) * width);
                            this.surface.setTile(0, 0, f, 1);
                        }
                        this.surface.setSurface(image);
                }
                surface.setShader(this.surface);
            case Tile(x, y, w, h, image, cc):
                this.surface ??= crow.application.backend.shader(SurfaceShader.label);
                this.surface.setSurface(image);
                this.surface.setTile(x, y, w, h);
                surface.setColor(cc);
                surface.setShader(this.surface);
            case Shader(s):
                surface.setShader(s);
            case null:
                colored ??= crow.application.backend.shader(ColoredShader.label);
                colored.setColor(colorId);
                surface.setShader(colored);
        }
    }
    
    override function onGizmoEvent(event:GizmoEvent) {
        if (!isActive) return;
        var ox = x + w / 2;
        var oy = y + h / 2;
        var length = 30;
        var thickness = 2;
        event.surface.setShader(event.surface.coloredShader);
        // x
        event.surface.coloredShader.setColor(Red);
        event.surface.drawLine(ox, oy, ox + length, oy, thickness);
        event.surface.flush();
        // y
        event.surface.coloredShader.setColor(Green);
        event.surface.drawLine(ox, oy, ox, oy + length, thickness);
        event.surface.flush();
        
        var area = getArea();
        if (area.isDragging) {
            x += area.mouseDelta.x;
            y += area.mouseDelta.y;
            event.isCancelled = true;
        }
    }



    public function buildTransform() {
        local.setIdentity().setTranslation(
            // MathUtils.lerp(pivotX, -1, 0, 1, w),
            // MathUtils.lerp(pivotY, -1, 0, 1, h)
            w / 2, h / 2,
        ).translate(x, y);
        if (parent == null || parent.kind != Kind.Widget) {
            world.load(local).multMat(transform);
        } else {
            var parent:Widget = getParent();
            parentInverse.load(parent.local).inverse().multMat(local);
            world.load(parent.world).multMat(parentInverse).multMat(transform);
        }
    }

    public function getSatge():StageGui {
        var current:Component = this;
        while (current != null) {
            if (current.getType() == StageGui) return cast current;
            current = current.parent;
        }
        return null;
    }

    @:eventHandler
    public function onDrawWidgetEvent(event:DrawWidgetEvent) {
        colored ??= crow.application.backend.shader(ColoredShader.label);
        gradient ??= crow.application.backend.shader(GradientShader.label);

        var hasBorder = true;
        var dl = 0.0;
        var dt = 0.0;
        var dr = 0.0;
        var db = 0.0;
        switch (borderWidth) {
            case null:
                hasBorder = false;
            case All(v):
                dl = dt = dr = db = v;
            case Only(l, t, r, b):
                dl = l;
                dt = t;
                dr = r;
                db = b;
        }

        var hasRadius = true;
        var tl = 0.0;
        var tr = 0.0;
        var br = 0.0;
        var bl = 0.0;
        switch (borderRadius) {
            case null:
                hasRadius = false;
            case All(v):
                tl = tr = br = bl = v;
            case Only(topLeft, topRight, bottomRight, bottomLeft):
                tl = topLeft;
                tr = topRight;
                br = bottomRight;
                bl = bottomLeft;
        }

        event.buffer.pushTransform(world);

        // @todo borderPosition
        if (!color.equals(Color(Transparent))) {
            if (hasBorder) {
                if (hasRadius) {
                    setupFill(event.buffer, borderColor);
                    event.buffer.drawRoundedRect(
                        MathUtils.mix(pivotX, -w / 2, -w),
                        MathUtils.mix(pivotY, -h / 2, -h),
                        w, h,
                        tl, tr, br, bl
                    );
                    event.buffer.flush();
                    event.buffer.setColor(null);
    
                    setupFill(event.buffer, color, 7);
                    event.buffer.drawRoundedRect(
                        MathUtils.mix(pivotX, -w / 2, -w) + dl,
                        MathUtils.mix(pivotY, -h / 2, -h) + dt,
                        w - (dl + dr),
                        h - (dt + db),
                        Math.max(tl - Math.max(dl, dt), 0),
                        Math.max(tr - Math.max(dt, dr), 0),
                        Math.max(br - Math.max(dr, db), 0),
                        Math.max(bl - Math.max(db, dl), 0)
                    );
                    event.buffer.flush();
                    event.buffer.setColor(null);
                } else {
                    setupFill(event.buffer, borderColor);
                    event.buffer.drawRect(MathUtils.mix(pivotX, -w / 2, -w), MathUtils.mix(pivotY, -h / 2, -h), w, h);
                    event.buffer.flush();
                    event.buffer.setColor(null);
    
                    setupFill(event.buffer, color, 7);
                    event.buffer.drawRect(MathUtils.mix(pivotX, -w / 2, -w) + dl, MathUtils.mix(pivotY, -h / 2, -h) + dt, w - (dl + dr), h - (dt + db));
                    event.buffer.flush();
                    event.buffer.setColor(null);
                }
            } else {
                if (hasRadius) {
                    setupFill(event.buffer, color);
                    event.buffer.drawRoundedRect(MathUtils.mix(pivotX, -w / 2, -w), MathUtils.mix(pivotY, -h / 2, -h), w, h, tl, tr, br, bl);
                    event.buffer.flush();
                } else {
                    setupFill(event.buffer, color);
                    event.buffer.drawRect(MathUtils.mix(pivotX, -w / 2, -w), MathUtils.mix(pivotY, -h / 2, -h), w, h);
                    event.buffer.flush();
                }
                event.buffer.setColor(null);
            }
        }
        
        // if (onDraw != null) onDraw(this, event); // @todo

        event.buffer.popTransform();
    }

    @:eventHandler
    override function onValidateEvent(event:ValidateEvent) {
        if (parent == null || parent.kind != Kind.Widget) return;
        var parent:Widget = getParent();
        
        // @todo вернуть? но с учётом minWidth
        // if (parent.horizontal.match(Hug) && horizontal.match(Fill))
        //     throw 'Hug and Fill: ${parent.label}';
        // if (parent.vertical.match(Hug) && vertical.match(Fill))
        //     throw 'Hug and Fill: ${parent.label}';
        // if (parent.getType() == LayoutWidget.type) {
        //     var parent:LayoutWidget = getParent();
        //     if (parent.wrap && (horizontal.match(Fill) || vertical.match(Fill)))
        //         throw 'Wrap and Fill: ${parent.label}';
        // }
    }

    @:eventHandler
    function onSizeEvent(event:SizeEvent) {}
    @:eventHandler
    function onLayoutEvent(event:LayoutEvent) {}
    @:eventHandler
    public function onPositionEvent(event:PositionEvent) {}

    public function getAABB() {
        var x = MathUtils.mix(pivotX, -w / 2, -w);
        var y = MathUtils.mix(pivotY, -h / 2, -h);
        
        world.multVec(ul.set(x, y));
        world.multVec(ur.set(x + w, y));
        world.multVec(bl.set(x, y + h));
        world.multVec(br.set(x + w, y + h));
        
        var left = Math.min(Math.min(ul.x, ur.x), Math.min(bl.x, br.x));
        var right = Math.max(Math.max(ul.x, ur.x), Math.max(bl.x, br.x));
        var top = Math.min(Math.min(ul.y, ur.y), Math.min(bl.y, br.y));
        var bottom = Math.max(Math.max(ul.y, ur.y), Math.max(bl.y, br.y));
        
        aabb.setCorners(left, top, right, bottom);
        return aabb;
    }

    public function getArea() {
        return getAABB();
    }
    
    @:eventHandler
    public function onInputEvent(event:InputEvent) {
        getAABB().update(event.mouse.x, event.mouse.y, event.mouse.isLeftDown);
        if (onInput != null) {
            var s = onInput(event);
            if (!s) event.isCancelled = true;
        }
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}