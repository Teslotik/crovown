package crovown.component.widget;

import crovown.event.Event;
import crovown.ds.Matrix;
import crovown.ds.Vector;
import crovown.event.InputEvent;
import crovown.event.LayoutEvent;

@:build(crovown.Macro.component(false))
class DpiWidget extends Widget {
    @:p public var dpi:Float = 1920.0 / 2.54;
    @:p public var enableDpiSupport:Bool = true;
    
    public var scale(get, never):Float;
    function get_scale() return w / 2.54 / dpi;

    var supportMatrix = Matrix.Identity();

    public static function build(crow:Crovown, component:DpiWidget) {
        return component;
    }

    @:eventHandler
    override function onLayoutEvent(event:LayoutEvent) {
        var widgets:Array<Widget> = getChildren();

        if (!enableDpiSupport) {
            for (child in widgets) {
                if (!child.isEnabled) continue;
                child.w = w;
                child.h = h;
            }
            return;
        }

        var width = w / scale;
        var height = h / scale;
        for (child in widgets) {
            if (!child.isEnabled) continue;
            child.w = width;
            child.h = height;
            child.transform.setScale(
                scale, scale
            ).setTranslation(
                w / 2 - width / 2,
                h / 2 - height / 2
            );
        }
    }

    override function dispatch(event:Event, self:Bool = true, forward:Bool = true, reversed:Bool = false) {
        if (enableDpiSupport && event.getType() == InputEvent.type) {
            supportMatrix.setScale(1 / scale, 1 / scale).multVec(cast(event, InputEvent).position);
        }
        super.dispatch(event, self, forward, reversed);
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}