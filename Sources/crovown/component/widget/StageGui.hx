package crovown.component.widget;

import crovown.backend.LimeBackend.LimeSurface;
import crovown.application.Application;
import crovown.backend.Backend.SurfaceShader;
import crovown.component.widget.Widget;
import crovown.ds.Matrix;
import crovown.ds.Signal.Slot;
import crovown.event.DrawWidgetEvent;
import crovown.event.GizmoEvent;
import crovown.event.InputEvent;
import crovown.event.LayoutEvent;
import crovown.event.PositionEvent;
import crovown.event.SizeEvent;
import crovown.types.Kind;

@:build(crovown.Macro.component(false))
class StageGui extends Component {
    @:p public var camera:Matrix = null;

    var calcSlot:Slot<Application->Void> = null;
    var drawSlot:Slot<Application->Void> = null;
    var resizeSlot:Slot<Application->Int->Int->Void> = null;

    var inputEvent:InputEvent = null;
    var drawWidgetEvent:DrawWidgetEvent = null;
    var gizmoEvent:GizmoEvent = null;
    
    var mixer:SurfaceShader = null;

    public function new() {
        super();
        kind = Kind.StageGui;
    }

    public static function build(crow:Crovown, component:StageGui) {
        component.calcSlot = crow.application.onRender.subscribe(Std.string(component.id) + "calc", app -> {
            component.inputEvent ??= new InputEvent();
            component.drawWidgetEvent ??= new DrawWidgetEvent(app.backend, app.displayWidth, app.displayHeight);
            component.gizmoEvent ??= new GizmoEvent(app.backend, app.displayWidth, app.displayHeight);
            component.mixer ??= app.backend.shader(SurfaceShader.label);

            component.apply(component -> component.invalidate(), null, false);

            var widgets:Array<Widget> = component.getChildren();
            for (widget in widgets) {
                widget.x = 0;
                widget.y = 0;
                widget.w = crow.application.w;
                widget.h = crow.application.h;
                // widget.w = crow.application.w / app.scale;
                // widget.h = crow.application.h / app.scale;
                // widget.transform
                //     .setScale(app.scale, app.scale)
                //     .setTranslation(crow.application.w / 2 - widget.w / 2, crow.application.h / 2 - widget.h / 2);
            }
            
            var mouse = crow.application.backend.mouse(0);
            var input = crow.application.backend.input(0);
            component.inputEvent.isCancelled = false;
            component.inputEvent.mouse = mouse;
            component.inputEvent.input = input;
            component.inputEvent.position.set(mouse.x, mouse.y);
            component.dispatch(component.inputEvent, true, false, true);
            app.backend.input(0).update();

            // @todo buildTransform()
            // @note @todo эксперементальный режим - в оригинале сначала LayoutEvent перед SizeEvent
            component.dispatch(new SizeEvent(), true, false);
            component.dispatch(new LayoutEvent());
            component.dispatch(new PositionEvent());
        });

        component.drawSlot = crow.application.onRender.subscribe(Std.string(component.id) + "draw", app -> {
            // @todo clear scissors

            // Drawing widgets
            component.drawWidgetEvent.setCamera(app.w, app.h);
            component.drawWidgetEvent.isCancelled = false;
            component.dispatch(component.drawWidgetEvent);
            // Mixing
            crow.application.surface.setShader(component.mixer);
            component.mixer.setSurface(component.drawWidgetEvent.buffer);
            crow.application.surface.drawSubRect(0, 0, app.w, app.h);
            // crow.application.surface.fill();
            crow.application.surface.flush();

            // Drawing gizmos
            // component.gizmoEvent.setCamera(app.w, app.h);
            // component.gizmoEvent.isCancelled = false;
            // component.gizmoEvent.input = app.backend.input(0);
            // component.dispatch(component.gizmoEvent, true, false, false);    // @todo
            // Mixing
            // crow.application.surface.setShader(component.mixer);
            // component.mixer.setSurface(component.gizmoEvent.surface);
            // crow.application.surface.drawSubRect(0, 0, app.w, app.h);
            // crow.application.surface.flush();
        }, Low);

        component.resizeSlot = crovown.application.Application.onDisplayResize.subscribe((app, w, h) -> {
            component.rebuild(crow);
        });

        return component;
    }

    override public function dispose() {
        super.dispose();

        calcSlot.unsubscribe();
        drawSlot.unsubscribe();
        resizeSlot.unsubscribe();

        calcSlot = null;
        drawSlot = null;
        resizeSlot = null;
    }
}