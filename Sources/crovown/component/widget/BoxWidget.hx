package crovown.component.widget;

import crovown.event.LayoutEvent;
import crovown.event.PositionEvent;
import crovown.algorithm.Geometry;

@:build(crovown.Macro.component(false))
class BoxWidget extends Widget {
    public static function build(crow:Crovown, component:BoxWidget) {
        return component;
    }

    @:eventHandler
    override function onLayoutEvent(event:LayoutEvent) {
        var widgets:Array<Widget> = getChildren();
        for (child in widgets) {
            if (!child.isEnabled) continue;
            Geometry.anchor(child.left, child.right, w, child.w, null, v -> child.w = v);
            Geometry.anchor(child.top, child.bottom, h, child.h, null, v -> child.h = v);
        }
    }

    @:eventHandler
    override function onPositionEvent(event:PositionEvent) {
        var widgets:Array<Widget> = getChildren();
        for (child in widgets) {
            if (!child.isEnabled) continue;
            Geometry.anchor(child.left, child.right, w, child.w, v -> child.x = v + x);
            Geometry.anchor(child.top, child.bottom, h, child.h, v -> child.y = v + y);
        }
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}