package crovown.component.widget;

import crovown.event.LayoutEvent;
import crovown.algorithm.MathUtils;
import crovown.event.SizeEvent;
import crovown.Crovown;
import crovown.algorithm.Geometry;
import crovown.component.widget.Widget;
import crovown.event.InputEvent;
import crovown.event.PositionEvent;
import crovown.types.Resizing;

using Lambda;

@:build(crovown.Macro.component())
class ScrollWidget extends Widget {
    @:p public var viewX:Null<Float> = null;
    @:p public var viewY:Null<Float> = null;

    public static function build(crow:Crovown, component:ScrollWidget) {
        return component;
    }

    @:eventHandler
    override public function onSizeEvent(event:SizeEvent) {
        var children:Array<Widget> = getChildren();
        if (horizontal.match(Resizing.Hug)) w = children.fold((i, r) -> Math.max(r, i.w), 0.0);
        if (vertical.match(Resizing.Hug)) h = children.fold((i, r) -> Math.max(r, i.h), 0.0);
    }

    @:eventHandler
    override public function onLayoutEvent(event:LayoutEvent) {
        var children:Array<Widget> = getChildren();
        for (child in children) {
            if (child.horizontal.match(Resizing.Fill)) child.w = w;
            if (child.vertical.match(Resizing.Fill)) child.h = h;
        }
    }

    @:eventHandler
    override function onPositionEvent(event:PositionEvent) {
        var widgets:Array<Widget> = getChildren();
        for (child in widgets) {
            if (!child.isEnabled) continue;
            Geometry.anchor(child.left, child.right, w, child.w, v -> child.x = v + x + viewX ?? 0.0);
            Geometry.anchor(child.top, child.bottom, h, child.h, v -> child.y = v + y + viewY ?? 0.0);
        }
    }

    @:eventHandler
    override function onInputEvent(event:InputEvent) {
        if (!isEnabled) return; // @todo перенести во все виджеты с обработкой ввода?
        super.onInputEvent(event);
        if (event.isCancelled) return;
        var area = getArea();
        var children:Array<Widget> = getChildren();
        
        // @todo clamp flag?
        if (viewY != null) {
            var height = children.fold((i, r) -> i.h + r, 0);
            if (area.isDragging) {
                viewY += area.mouseDelta.y;
                event.isCancelled = true;
            } else if (area.isOver && event.mouse.wheelDeltaY != 0) {
                viewY += event.mouse.wheelDeltaY * 30;
                event.isCancelled = true;
            } else if (viewY + height < Math.min(h, height)) {
                viewY = MathUtils.mix(10 * crow.application.deltaTime, viewY, Math.min(height, h) - height);
            } else if (viewY > 0) {
                viewY = MathUtils.mix(10 * crow.application.deltaTime, viewY, 0);
            }
        }

        if (viewX != null) {
            var width = children.fold((i, r) -> i.w + r, 0);
            if (area.isDragging) {
                viewX += area.mouseDelta.x;
                event.isCancelled = true;
            } else if (area.isOver && event.mouse.wheelDeltaX != 0) {
                viewX += event.mouse.wheelDeltaX * 30;
                event.isCancelled = true;
            } else if (viewX + width < Math.min(w, width)) {
                viewX = MathUtils.mix(10 * crow.application.deltaTime, viewX, Math.min(width, w) - width);
            } else if (viewX > 0) {
                viewX = MathUtils.mix(10 * crow.application.deltaTime, viewX, 0);
            }
        }

        if (area.wasDown) event.isCancelled = true;
    }
}