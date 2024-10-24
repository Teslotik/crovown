package crovown.component.widget;

import crovown.event.InputEvent;
import crovown.backend.Backend.Mouse;
import crovown.component.widget.Widget;
import crovown.component.widget.LayoutWidget;

using Lambda;

// @todo rename
@:build(crovown.Macro.component(false))
class RadioProperty extends LayoutWidget {
    @:p public var onChange:RadioProperty->Void = null;

    public var active:Widget = null;

    public static function build(crow:Crovown, component:RadioProperty) {
        return component;
    }

    override function onInputEvent(event:InputEvent) {
        super.onInputEvent(event);
        if (event.isCancelled) return;
        var children:Array<Widget> = getChildren();
        var active = children.find(c -> c.isActive && c != active);
        if (active != null) {
            if (this.active != null) this.active.isActive = false;
            this.active = active;
            if (onChange != null) onChange(this);
        }
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}