package crovown.component.widget;

import crovown.event.PositionEvent;
import crovown.event.DrawWidgetEvent;
import crovown.ds.Vector;
import crovown.backend.Backend.Mouse;
import crovown.component.widget.StageGui;
import crovown.ds.Matrix;
import crovown.Crovown;
import crovown.component.widget.Widget;

@:build(crovown.Macro.component())
class ViewportWidget extends BoxWidget {
    @:p public var camera:Matrix = Matrix.Identity();
    @:p public var unit:Float = 1.0;

    var support = new Vector();
    var inverse = Matrix.Identity();

    public static function build(crow:Crovown, component:ViewportWidget) {
        return component;
    }

    @:eventHandler
    override function onDrawWidgetEvent(event:DrawWidgetEvent) {
        super.onDrawWidgetEvent(event);
        world.multMat(camera);
    }

    @:eventHandler
    override function onPositionEvent(event:PositionEvent) {
        var widgets:Array<Widget> = getChildren();
        for (child in widgets) {
            if (!child.isEnabled) continue;
            child.x = x + w / 2 - child.w / 2 + child.posX;
            child.y = y + h / 2 - child.h / 2 + child.posY;
        }
    }

    // override public function mouseInput(crow:Crovown, mouse:Mouse):Bool {
    //     // return super.mouseInput(crow, mouse);
    //     getAABB().update(mouse.x, mouse.y, mouse.isLeftDown);
    //     if (onMouseInput != null) return onMouseInput(this, mouse);
    //     return true;
    // }

    public inline function getCameraInverse() {
        return inverse.load(camera).inverse();
    }

    public function toLocal(x:Float, y:Float):Vector {
        support.set(x, y);
        getCameraInverse().multVec(support);
        return support.set(support.x / unit, support.y / unit);
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}
