package crovown.component.widget;

import crovown.algorithm.MathUtils;
import crovown.event.ValidateEvent;
import crovown.event.SizeEvent;
import crovown.event.LayoutEvent;
import crovown.event.PositionEvent;
import crovown.types.Gap;
import crovown.algorithm.Geometry;
import crovown.types.Resizing;
import crovown.types.Layout;

using Lambda;

@:build(crovown.Macro.component(false))
class LayoutWidget extends Widget {
    @:p public var direction:Layout = Layout.Row;
    @:p public var gap:Gap = Gap.Fixed(0);
    @:p public var padding(null, set):Float;    // @todo never
    function set_padding(v:Float):Float {
        return paddingLeft = paddingTop = paddingRight = paddingBottom = v;
    }
    @:p public var paddingLeft:Float = 0.0;
    @:p public var paddingTop:Float = 0.0;
    @:p public var paddingRight:Float = 0.0;
    @:p public var paddingBottom:Float = 0.0;
    @:p public var wrap:Bool = false;
    @:p public var hjustify:Float = -1.0;
    @:p public var vjustify:Float = -1.0;

    public static function build(crow:Crovown, component:LayoutWidget) {
        return component;
    }

    @:eventHandler
    override function onValidateEvent(event:ValidateEvent) {
        super.onValidateEvent(event);
        if (wrap && (horizontal.match(Hug) || vertical.match(Hug)))
            throw 'Wrap and Hug: ${label}';
    }

    @:eventHandler
    override function onSizeEvent(event:SizeEvent) {
        var children:Array<Widget> = getChildren();
        var gap = switch (gap) {
            case Fixed(v): v;
            case Even: 0;
        }
        
        if (direction.match(Row)) {
            if (horizontal.match(Resizing.Hug)) {
                w = children.fold((w, r) -> r + w.w, 0) + Geometry.space(gap, children.length) + (paddingLeft + paddingRight);
            }
            if (vertical.match(Resizing.Hug)) {
                h = children.fold((w, r) -> Math.max(w.h, r), 0) + (paddingTop + paddingBottom);
            }
        } else if (direction.match(Column)) {
            if (horizontal.match(Resizing.Hug)) {
                w = children.fold((w, r) -> Math.max(w.w, r), 0) + (paddingLeft + paddingRight);
            }
            if (vertical.match(Resizing.Hug)) {
                h = children.fold((w, r) -> r + w.h, 0) + Geometry.space(gap, children.length) + (paddingTop + paddingBottom);
            }
        }
    }

    @:eventHandler
    override function onLayoutEvent(event:LayoutEvent) {
        var children:Array<Widget> = getChildren();

        var filled = 0;     // count of the children with Resizing == Fill
        var free = 0.0;     // space of the container that is not occupied by its children
        if (direction.match(Row)) {
            filled = children.count(w -> w.horizontal.match(Resizing.Fill));
            free = if (filled > 0) w - children.fold((w, r) -> r + (w.horizontal.match(Resizing.Fill) ? 0.0 : w.w), 0) else w;
            free -= paddingLeft + paddingRight;
        } else if (direction.match(Column)) {
            filled = children.count(w -> w.vertical.match(Resizing.Fill));
            free = if (filled > 0) h - children.fold((w, r) -> r + (w.vertical.match(Resizing.Fill) ? 0.0 : w.h), 0) else h;
            free -= paddingTop + paddingBottom;
        }

        // Distributing free space between children
        var size = if (gap.match(Gap.Even)) {
            var even = filled + Math.max(children.length - 1, 0);
            if (even > 0) free / even else 0;
        } else {
            var gap = switch (gap) {
                case Fixed(v): v;
                case Even: 0;
            }
            var fixed = free - Geometry.space(gap, children.length);
            if (filled > 0) fixed / filled else 0;
        }
        
        // Assign free space
        if (direction.match(Row)) {
            for (child in children) {
                if (child.horizontal.match(Resizing.Fill)) child.w = size;
            }
        } else if (direction.match(Column)) {
            for (child in children) {
                if (child.vertical.match(Resizing.Fill)) child.h = size;
            }
        }
        
        // Assign size of the parent
        if (direction.match(Row)) {
            for (child in children) {
                if (child.vertical.match(Resizing.Fill)) child.h = h - (paddingTop + paddingBottom);
            }
        } else if (direction.match(Column)) {
            for (child in children) {
                if (child.horizontal.match(Resizing.Fill)) child.w = w - (paddingLeft + paddingRight);
            }
        }
    }

    @:eventHandler
    override function onPositionEvent(event:PositionEvent) {
        var children:Array<Widget> = getChildren();
        var gap = switch (gap) {
            case Fixed(v): v;
            case Even: 0;
        }
        
        var cx = x + paddingLeft;
        var cy = y + paddingTop;
        var cw = w - (paddingLeft + paddingRight);
        var ch = h - (paddingTop + paddingBottom);

        var width = 0.0;
        var height = 0.0;
        if (direction.match(Row)) {
            if (wrap) {
                width = cw;
                var i = 0;
                var dy = 0.0;
                var rows = 0;
                while (i < children.length) {
                    // Counting widgets in the row
                    var count = 0;
                    var size = 0.0;
                    for (j in i...children.length) {
                        var child = children[j];
                        if (size + child.w + gap > width) {
                            if (count == 0) count = 1;
                            break;
                        }
                        size += child.w + gap;
                        count++;
                    }

                    // Calculating max height in the row
                    var h = 0.0;
                    for (j in 0...count) {
                        h = Math.max(children[j + i].h, h);
                    }

                    // Locating widgets in the row
                    var dx = 0.0;
                    for (j in 0...count) {
                        var child = children[j + i];
                        child.x = dx;
                        child.y = dy + Geometry.locate(child.align, 0, h, child.h);
                        dx += child.w + gap;
                    }
                    rows++;
                    i += count;
                    dy += h + gap;
                    height += h;
                }
                height += Geometry.space(gap, rows);
            } else {
                var w = children.fold((c, r) -> r + c.w, 0.0);
                width = if (this.gap.match(Gap.Even)) {
                    children.length == 1 ? children[0].w : cw;
                } else {
                    w + Geometry.space(gap, children.length);
                }
                height = Math.min(
                    children.fold((c, r) -> Math.max(c.h, r), 0),
                    h - (paddingTop + paddingBottom)
                );
                var spacing = this.gap.match(Fixed(_)) ? gap : Geometry.distribute(width - w, children.length);

                var dx = 0.0;
                for (child in children) {
                    child.x = dx;
                    child.y = Geometry.locate(child.align, 0, height, child.h);
                    dx += child.w + spacing;
                }
            }
        } else if (direction.match(Column)) {
            if (wrap) {
                height = ch;
                var i = 0;
                var dx = 0.0;
                var cols = 0;
                while (i < children.length) {
                    // Counting widgets in the column
                    var count = 0;
                    var size = 0.0;
                    for (j in i...children.length) {
                        var child = children[j];
                        if (size + child.h + gap > height) {
                            if (count == 0) count = 1;
                            break;
                        }
                        size += child.h + gap;
                        count++;
                    }

                    // Calculating width in the column
                    var w = 0.0;
                    for (j in 0...count) {
                        w = Math.max(children[j + i].w, w);
                    }

                    // Locating widgets in the column
                    var dy = 0.0;
                    for (j in 0...count) {
                        var child = children[j + i];
                        child.x = dx + Geometry.locate(child.align, 0, w, child.w);
                        child.y = dy;
                        dy += child.h + gap;
                    }
                    cols++;
                    i += count;
                    dx += w + gap;
                    width += w;
                }
                width += Geometry.space(gap, cols);
            } else {
                var h = children.fold((c, r) -> r + c.h, 0.0);
                height = if (this.gap.match(Gap.Even)) {
                    children.length == 1 ? children[0].h : ch;
                } else {
                    h + Geometry.space(gap, children.length);
                }
                width = Math.min(
                    children.fold((c, r) -> Math.max(c.w, r), 0),
                    w - (paddingLeft + paddingRight)
                );
                var spacing = this.gap.match(Fixed(_)) ? gap : Geometry.distribute(height - h, children.length);

                var dy = 0.0;
                for (child in children) {
                    child.x = Geometry.locate(child.align, 0, width, child.w);
                    child.y = dy;
                    dy += child.h + spacing;
                }
            }
        }
        
        // Justify
        for (child in children) {
            child.x += Geometry.locate(hjustify, cx, cw, width);
            child.y += Geometry.locate(vjustify, cy, ch, height);
        }
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}