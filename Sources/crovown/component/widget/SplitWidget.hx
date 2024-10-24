package crovown.component.widget;

import crovown.ds.Vector;
import crovown.event.LayoutEvent;
import crovown.event.SizeEvent;
import crovown.event.InputEvent;
import crovown.event.PositionEvent;
import crovown.algorithm.MathUtils;
import crovown.backend.Backend.Mouse;
import crovown.component.Component;
import crovown.component.widget.Widget;
import crovown.types.Anchor;
import crovown.types.Gap;
import crovown.types.Layout;
import crovown.types.Resizing;

using crovown.component.widget.BoxWidget;

// @todo учитывать minW, minH у first и second
@:build(crovown.Macro.component(false))
class SplitWidget extends Widget {
    @:p public var onChange:Anchor->Void = null;

    @:p public var first(default, set):Widget = null;
    function set_first(v:Widget):Widget {
        removeChild(first);
        insertChild(0, v);
        return first = v;
    }

    @:p public var second(default, set):Widget = null;
    function set_second(v:Widget):Widget {
        removeChild(second);
        insertChild(1, v);
        return second = v;
    }

    @:p public var splitter(default, set):Widget = null;
    function set_splitter(v:Widget):Widget {
        removeChild(splitter);
        insertChild(2, v);
        return splitter = v;
    }

    @:p public var direction:Layout = Layout.Row;
    @:p public var gap:Gap = Gap.Fixed(0);
    @:p public var padding(null, set):Float;    // @todo never instead of null
    function set_padding(v:Float):Float {
        return paddingLeft = paddingTop = paddingRight = paddingBottom = v;
    }
    @:p public var paddingLeft:Float = 0.0;
    @:p public var paddingTop:Float = 0.0;
    @:p public var paddingRight:Float = 0.0;
    @:p public var paddingBottom:Float = 0.0;
    
    @:p public var pos(default, set):Anchor = Scale(0.5);
    function set_pos(v:Anchor):Anchor {
        return pos = switch (v) {
            case Fixed(v): Fixed(MathUtils.clamp(v, minPos, maxPos));
            case Scale(v): Scale(MathUtils.clamp(v, minPos, maxPos));
            case Center(v): Center(MathUtils.clamp(v, minPos, maxPos));
        }
    }
    @:p public var minPos:Null<Float> = 0.0;
    @:p public var maxPos:Null<Float> = null;

    public static function build(crow:Crovown, component:SplitWidget) {
        component.splitter ??= crow.BoxWidget(widget -> {
            widget.label = "splitter";
            widget.color = crovown.types.Fill.Color(crovown.types.Color.Blue); // @todo удалить префикс у цвета
            widget.horizontal = Fixed(20);
            widget.vertical = Fixed(20);
        });

        // component.color = Color(Transparent);
        component.first ??= component.getChildAt(0);
        component.second ??= component.getChildAt(1);
        component.splitter ??= component.getChildAt(2);

        return component;
    }

    @:eventHandler
    override function onSizeEvent(event:SizeEvent) {
        var gap = switch (gap) {
            case Fixed(v): v;
            case Even: 0;
        }
        
        if (direction.match(Row)) {
            if (horizontal.match(Resizing.Hug)) {
                w = first.w + second.w + gap + (paddingLeft + paddingRight);
            }
            if (vertical.match(Resizing.Hug)) {
                h = Math.max(first.h, second.h) + (paddingTop + paddingBottom);
            }
        } else if (direction.match(Column)) {
            if (horizontal.match(Resizing.Hug)) {
                w = Math.max(first.w, second.w) + (paddingLeft + paddingRight);
            }
            if (vertical.match(Resizing.Hug)) {
                h = first.h + second.h + gap + (paddingTop + paddingBottom);
            }
        }
    }

    // Assuming that the first and the second are always has Fill resizing
    @:eventHandler
    override function onLayoutEvent(event:LayoutEvent) {
        var gap = switch (gap) {
            case Fixed(v): v;
            case Even: 0;
        }

        if (direction.match(Row)) {
            var free = w - (paddingLeft + paddingRight) - gap;
            var width = MathUtils.clamp(switch (pos) {
                case Fixed(v): v;
                case Scale(v): free * v;
                case Center(v): free / 2 + v;
            }, 0, free);
            var height = h - (paddingTop + paddingBottom);
            first.w = width;
            second.w = free - width;
            first.h = height;
            second.h = height;
            splitter.h = height;
        } else if (direction.match(Column)) {
            var free = h - (paddingTop + paddingBottom) - gap;
            var height = MathUtils.clamp(switch (pos) {
                case Fixed(v): v;
                case Scale(v): free * v;
                case Center(v): free / 2 + v;
            }, 0, free);
            var width = w - (paddingLeft + paddingRight);
            first.h = height;
            second.h = free - height;
            first.w = width;
            second.w = width;
            splitter.w = width;
        }
    }

    @:eventHandler
    override function onPositionEvent(event:PositionEvent) {
        first.x = x + paddingLeft;
        first.y = y + paddingTop;
        second.x = x + w - paddingRight - second.w;
        second.y = y + h - paddingBottom - second.h;
        if (direction.match(Row)) {
            splitter.x = ((first.x + first.w) + second.x) / 2 - splitter.w / 2;
            splitter.y = y + paddingTop;
        } else if (direction.match(Column)) {
            splitter.x = x + paddingLeft;
            splitter.y = ((first.y + first.h) + second.y) / 2 - splitter.h / 2;
        }
    }

    var mouse = new Vector();

    @:eventHandler
    override function onInputEvent(event:InputEvent) {
        super.onInputEvent(event);

        var lastPos = pos;
        var drag = drag ?? _ -> splitter.getArea();
        if (drag(this).isDragging) {
            if (direction.match(Row)) {
                pos = switch (pos) {
                    case Fixed(v): Fixed(MathUtils.clamp(
                        MathUtils.lerp(event.position.x, x + paddingLeft, 0, x + w - paddingRight, w), 0, w
                    ));
                    case Scale(v): Scale(MathUtils.clamp(
                        MathUtils.lerp(event.position.x, x + paddingLeft, 0, x + w - paddingRight, 1), 0, 1
                    ));
                    case Center(v):
                        var center = (w - (paddingLeft + paddingRight)) / 2;
                        Center(MathUtils.clamp(
                            MathUtils.lerp(event.position.x, x + paddingLeft, -center, x + w - paddingRight, center), -center, center
                        ));
                }
                // event.isCancelled = true;
            } else if (direction.match(Column)) {
                pos = switch (pos) {
                    case Fixed(v): Fixed(MathUtils.clamp(
                        MathUtils.lerp(event.position.y, y + paddingTop, 0, y + h - paddingBottom, h), 0, h
                    ));
                    case Scale(v): Scale(MathUtils.clamp(
                        MathUtils.lerp(event.position.y, y + paddingTop, 0, y + h - paddingBottom, 1), 0, 1
                    ));
                    case Center(v):
                        var center = (h - (paddingTop + paddingBottom)) / 2;
                        Center(MathUtils.clamp(
                            MathUtils.lerp(event.position.y, y + paddingTop, -center, y + h - paddingBottom, center), -center, center
                        ));
                }
                // event.isCancelled = true;
            }
            if (onChange != null && !pos.equals(lastPos)) onChange(pos);
        }
        if (drag(this).wasDown) event.isCancelled = true;
        // return !isOver && !isDragging;
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}