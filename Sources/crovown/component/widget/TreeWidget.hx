package crovown.component.widget;

import crovown.event.LayoutEvent;
import crovown.event.SizeEvent;
import crovown.event.PositionEvent;
import crovown.event.DrawWidgetEvent;
import crovown.event.InputEvent;
import crovown.algorithm.Geometry;
import crovown.types.Gap;
import crovown.backend.Backend.Mouse;
import crovown.component.widget.StageGui;
import crovown.component.Component;
import crovown.types.Resizing;
import crovown.types.Layout;

using crovown.component.widget.LayoutWidget;
using crovown.component.widget.Widget;
// using crovown.component.widget.TreeWidget.TreeItem;

using Lambda;

@:build(crovown.Macro.component())
class TreeItem extends Widget {
    @:p public var direction:Layout = Layout.Column;
    @:p public var gap:Gap = Gap.Fixed(0);
    @:p public var padding(null, set):Float;    // @todo never
    function set_padding(v:Float):Float {
        return paddingLeft = paddingTop = paddingRight = paddingBottom = v;
    }
    @:p public var paddingLeft:Float = 0.0;
    @:p public var paddingTop:Float = 0.0;
    @:p public var paddingRight:Float = 0.0;
    @:p public var paddingBottom:Float = 0.0;

    // @:p public var index:Int = 0;
    // @:p public var depth:Int = 0;
    @:p public var indent:Float = 12;

    @:p public var depth(default, set):Int = 0;
    function set_depth(v:Int) {
        var children:Array<TreeItem> = getChildren();
        for (child in children) child.depth = v + 1;
        return depth = v;
    }

    @:p public var delegate:Widget = null;

    public static function build(crow:Crovown, component:TreeItem) {
        // component.direction = Column;
        return component;
    }

    // @todo check functions call order e.t.c super.layout(); and then dlegate.layout(); or dlegate.layout(); and then super.layout();?

    @:eventHandler
    override function onSizeEvent(event:SizeEvent) {
        if (delegate == null) return;
        // delegate.apply(component -> cast(component, Widget).layout(), null, true);
        // delegate.apply(component -> cast(component, Widget).relative(), null, true);
        delegate.dispatch(event);

        var children:Array<Widget> = getChildren();
        var gap = switch (gap) {
            case Fixed(v): v;
            case Even: 0;
        }
        
        if (direction.match(Row)) {
            if (horizontal.match(Resizing.Hug)) {
                w = children.fold((w, r) -> r + w.w, 0) + delegate.w + Geometry.space(gap, children.length + 1) + (paddingLeft + paddingRight);
            }
            if (vertical.match(Resizing.Hug)) {
                h = Math.max(children.fold((w, r) -> Math.max(w.h, r), 0), delegate.h) + (paddingTop + paddingBottom) + indent * (depth + 1);
            }
        } else if (direction.match(Column)) {
            if (horizontal.match(Resizing.Hug)) {
                w = Math.max(children.fold((w, r) -> Math.max(w.w, r), 0), delegate.w) + (paddingLeft + paddingRight) + indent * (depth + 1);
            }
            if (vertical.match(Resizing.Hug)) {
                h = children.fold((w, r) -> r + w.h, 0) + delegate.h + Geometry.space(gap, children.length + 1) + (paddingTop + paddingBottom);
            }
        }
    }

    @:eventHandler
    override function onLayoutEvent(event:LayoutEvent) {
        if (delegate == null) return;
        var children:Array<TreeItem> = getChildren();

        var filled = 0;     // count of the children with Resizing == Fill
        var free = 0.0;     // space of the container that is not occupied by its children
        if (direction.match(Row)) {
            filled = children.count(w -> w.horizontal.match(Resizing.Fill)) + (delegate.horizontal.match(Fill) ? 1 : 0);
            free = if (filled > 0) w - children.fold((w, r) -> r + (w.horizontal.match(Resizing.Fill) ? 0.0 : w.w), 0) + (delegate.horizontal.match(Fill) ? delegate.w : 0) else w;
            free -= paddingLeft + paddingRight;
        } else if (direction.match(Column)) {
            filled = children.count(w -> w.vertical.match(Resizing.Fill)) + (delegate.vertical.match(Fill) ? 1 : 0);
            free = if (filled > 0) h - children.fold((w, r) -> r + (w.vertical.match(Resizing.Fill) ? 0.0 : w.h), 0) + (delegate.vertical.match(Fill) ? delegate.h : 0) else h;
            free -= paddingTop + paddingBottom;
        }

        // Distributing free space between children
        var size = if (gap.match(Gap.Even)) {
            var even = children.length + 1 - filled;    // @todo проверить правильность - в LayerWidget другая запись
            if (even > 0) free / even else 0;
        } else {
            var gap = switch (gap) {
                case Fixed(v): v;
                case Even: 0;
            }
            var fixed = free - Geometry.space(gap, children.length + 1);
            if (filled > 0) fixed / filled else 0;
        }


        // Assign free space
        if (direction.match(Row)) {
            if (delegate.horizontal.match(Fill)) delegate.w = size;
            for (child in children) {
                if (child.horizontal.match(Resizing.Fill)) child.w = size;
            }
        } else if (direction.match(Column)) {
            if (delegate.vertical.match(Fill)) delegate.h = size;
            for (child in children) {
                if (child.vertical.match(Resizing.Fill)) child.h = size;
            }
        }
        
        // Assign size of the parent
        if (direction.match(Row)) {
            if (delegate.vertical.match(Fill)) delegate.h = h - (paddingTop + paddingBottom);
            for (child in children) {
                if (child.vertical.match(Resizing.Fill)) child.h = h - indent * (depth + 1) - (paddingTop + paddingBottom);
            }
        } else if (direction.match(Column)) {
            if (delegate.horizontal.match(Fill)) delegate.w = w - (paddingTop + paddingBottom);
            for (child in children) {
                if (child.horizontal.match(Resizing.Fill)) child.w = w - indent * (depth + 1) - (paddingLeft + paddingRight);
            }
        }
        // delegate.apply(null, component -> cast(component, Widget).relative(), true);
        // delegate.apply(null, component -> cast(component, Widget).layout(), true);
        delegate?.dispatch(event, true, false);
    }

    @:eventHandler
    override function onPositionEvent(event:PositionEvent) {
        if (delegate == null) return;
        var children:Array<TreeItem> = getChildren();
        var gap = switch (gap) {
            case Fixed(v): v;
            case Even: throw "Even space in TreeItem is not implemented yet";   // @todo
        }
        if (direction.match(Row)) {
            delegate.x = x + paddingLeft;
            delegate.y = y + paddingTop;
            var dx = delegate.x + delegate.w + gap;
            for (child in children) {
                child.x = dx;
                child.y = y + paddingTop + indent * (depth + 1);
                dx += child.w + gap;
            }
        } else if (direction.match(Column)) {
            delegate.x = x + paddingLeft;
            delegate.y = y + paddingTop;
            var dy = delegate.y + delegate.h + gap;
            // trace(delegate.label, delegate.x, delegate.y, delegate.w, delegate.h);
            for (child in children) {
                child.x = x + paddingLeft + indent * (depth + 1);
                child.y = dy;
                // trace(child.label, child.x, child.y, child.w, child.h, child.indent, child.depth);
                dy += child.h + gap;
            }







            // @todo even spacing?
            // var h = children.fold((c, r) -> r + c.h, 0.0);
            // height = if (this.gap.match(Gap.Even)) {
            //     children.length == 1 ? children[0].h : ch;
            // } else {
            //     h + Geometry.space(gap, children.length);
            // }
            // width = Math.min(
            //     children.fold((c, r) -> Math.max(c.w, r), 0),
            //     w - (paddingLeft + paddingRight)
            // );
            // var spacing = this.gap.match(Fixed(_)) ? gap : Geometry.distribute(height - h, children.length);

            // var dy = 0.0;
            // for (child in children) {
            //     child.x = Geometry.locate(child.align, 0, width, child.w);
            //     child.y = dy;
            //     dy += child.h + spacing;
            // }
        }
        delegate?.dispatch(event);
    }

    // /*
    override function onDrawWidgetEvent(event:DrawWidgetEvent) {
        super.onDrawWidgetEvent(event);
        delegate?.dispatch(event);
    }

    // override function mouseInput(crow:Crovown, mouse:Mouse):Bool {
    //     // if (!delegate.mouseInput(crow, mouse)) return false;
    //     // return super.mouseInput(crow, mouse);

    //     // if (!StageGui.processMouse(delegate, component -> cast(component, Widget).mouseInput(crow, mouse), true)) return false;
    //     return super.mouseInput(crow, mouse);
    // }
    // */

    @:eventHandler
    override public function onInputEvent(event:InputEvent) {
        delegate?.dispatch(event, true, false, true);
        super.onInputEvent(event);
    }

    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}