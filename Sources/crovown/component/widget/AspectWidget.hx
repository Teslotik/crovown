package crovown.component.widget;

import crovown.event.LayoutEvent;
import crovown.component.widget.BoxWidget;
import crovown.component.widget.Widget;


@:build(crovown.Macro.component(false))
class AspectWidget extends BoxWidget {
    @:p public var ratio:Float = 1.0;

    public static function build(crow:Crovown, component:AspectWidget) {
        return component;
    }

    @:eventHandler
    override function onLayoutEvent(event:LayoutEvent) {
        var parent:Widget = getParent();
        var container = parent.getAABB();
        if (w / ratio < container.h) {
            h = w / ratio;
        } else {
            w = h * ratio;
        }
        super.onLayoutEvent(event);
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}