package crovown.component.widget;

import crovown.event.LayoutEvent;
import crovown.component.widget.Widget;

@:build(crovown.Macro.component(false))
class SpacerWidget extends Widget {
    @:p public var thickness:Float = 1.0;
    
    @:eventHandler
    override function onLayoutEvent(event:LayoutEvent) {
        var parent:LayoutWidget = getParent();
        // horizontal = (parent.horizontal.match(Hug)) ? Fixed(thickness) : Fill;
        // vertical = (parent.vertical.match(Hug)) ? Fixed(thickness) : Fill;
        if (parent.direction.match(Row)) {
            horizontal = Fixed(thickness);
            vertical = Fill;
        } else if (parent.direction.match(Column)) {
            horizontal = Fill;
            vertical = Fixed(thickness);
        }
    }

    public static function build(crow:Crovown, component:SpacerWidget) {
        component.horizontal = Fixed(0);
        component.vertical = Fixed(0);
        return component;
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}