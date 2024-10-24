package crovown.component.widget;

import crovown.event.LayoutEvent;
import crovown.event.SizeEvent;
import crovown.event.PositionEvent;
import crovown.event.DrawWidgetEvent;
import crovown.event.InputEvent;
import crovown.backend.Backend.Mouse;

@:build(crovown.Macro.component())
class MenuWidget extends Widget {
    @:p public var delegate:Widget = null;

    public static function build(crow:Crovown, component:MenuWidget) {
        return component;
    }

    @:eventHandler
    override function onSizeEvent(event:SizeEvent) {
        if (delegate == null) return;
        delegate.dispatch(event);
        w = delegate.w;
        h = delegate.h;
    }

    @:eventHandler
    override function onLayoutEvent(event:LayoutEvent) {
        delegate?.dispatch(event, true, false);
    }

    @:eventHandler
    override function onPositionEvent(event:PositionEvent) {
        if (delegate == null) return;
        delegate.x = x;
        delegate.y = y;
        delegate?.dispatch(event);
    }

    @:eventHandler
    override function onDrawWidgetEvent(event:DrawWidgetEvent) {
        super.onDrawWidgetEvent(event);
        delegate?.dispatch(event);
    }

    // override function mouseInput(crow:Crovown, mouse:Mouse) {
    //     if (delegate != null && !StageGui.processMouse(delegate, component -> cast(component, Widget).mouseInput(crow, mouse), true)) return false;
    //     if (!super.mouseInput(crow, mouse)) return false;
    //     var area = getArea();
    //     if (area.isEntered) {
    //         removeChildren();
    //         // trace("removed");
    //     }
    //     return !area.isOver;

    //     // var parent:Widget = getParent();
    //     // var area = parent.getArea();
    //     // if (area.isEntered) {
    //     //     parent.removeChild(this);super.mouseInput(crow, mouse);
    //     // }
    // }

    @:eventHandler
    override public function onInputEvent(event:InputEvent) {
        delegate?.dispatch(event, true, false, true);
        if (event.isCancelled) return;
        super.onInputEvent(event);
        if (event.isCancelled) return;
        var area = getArea();
        if (area.isEntered) {
            removeChildren();
            // trace("removed");
        }
        // return !area.isOver;
        if (area.isOver) event.isCancelled = true;
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}