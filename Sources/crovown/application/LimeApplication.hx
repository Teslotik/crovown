package crovown.application;

import lime.system.Clipboard;
import crovown.ds.Vector;
import crovown.ds.Matrix;
import crovown.Crovown.Action;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Touch;
import lime.ui.MouseWheelMode;
import lime.ui.MouseButton;
import lime.graphics.RenderContext;
import crovown.backend.LimeBackend;
import lime.graphics.OpenGLRenderContext;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.OpenGLES3RenderContext;

using Lambda;

class LimeApplication extends Application {
    // @todo реорганизовать код, чтобы было меньше блоков условий
    #if lime_opengl
	public var gl(default, null):OpenGLRenderContext = null;
    #elseif lime_webgl
	public var gl(default, null):WebGL2RenderContext = null;
    #elseif lime_opengles
	public var gl(default, null):OpenGLES3RenderContext = null;
	#end

    var prototype:lime.app.Application = null;

    public function new(prototype:lime.app.Application) {
        this.prototype = prototype;
        #if android
        isMobile = true;
        #end
        #if desktop
        isDesktop = true;
        #end
        super();
    }

    override function get_framerate():Null<Float> {
        return prototype.window.frameRate;
    }

    override function set_framerate(v:Null<Float>):Null<Float> {
        return prototype.window.frameRate = v ?? 30;
    }
    
    override public function minimize() {
        prototype.window.minimized = true;
        prototype.window.fullscreen = false;
    }

    override public function maximize() {
        prototype.window.maximized = !prototype.window.maximized;
    }

    override public function fullscreen() {
        prototype.window.fullscreen = !prototype.window.fullscreen;
        isFullscreen = prototype.window.fullscreen;
    }

    override public function stop() {
        prototype.window.close();
    }
    
    override function resize(w:Int, h:Int) {
        prototype.window.resize(w, h);
        prototype.onWindowResize(w, h);
    }

    // @todo toClipboard

    override function copy(v:String) {
        Clipboard.text = v;
    }

    override function paste() {
        return Clipboard.text;
    }

    public function render(gl) {
        // var backend = cast(backend, LimeBackend);
        this.gl = gl;

        surface.clear(Transparent);
        surface.clearTransform();
        surface.clearScissors();
        surface.pushTransform(Matrix.Orthogonal(0, w, h, 0, 0.1, 100));
        surface.pushTransform(Matrix.Translation(0, 0, -50));
        surface.viewport(0, 0, w, h);

        onRender.emit(slot -> slot(this));
        // backend.render(context);  // @note todo

        // @todo вынести?
        var keyboard = backend.input(0);
        for (a in keyboard.down.filter(a -> a.match(Char(_)))) {
            keyboard.release(a);
        }
    }

    override function windowResize(w:Int, h:Int) {
        super.windowResize(w, h);
        gl?.viewport(0, 0, w, h);
        surface?.viewport(0, 0, w, h);
    }
}

class LimeMain extends lime.app.Application {
    // var app = new LimeApplication();
    var app:LimeApplication = null;
    var touches = new Array<Touch>();

    public function new() {
        super();
    }
    
    override function render(context:RenderContext) {
        static var ready = false;
        if (!ready) {
            // window.resize(1080, 2220);
            app = new LimeApplication(this);
            ready = true;
        }
        if (!app.isLoaded) {
            // @todo менять и пересоздавать когда вращается экран телефона
            // app.displayWidth = Std.int(window.display.bounds.size.x);   // @todo width, height?
            // app.displayHeight = Std.int(window.display.bounds.size.y);
            app.displayWidth = Std.int(window.display.bounds.width);   // @todo width, height?
            app.displayHeight = Std.int(window.display.bounds.height);

            #if lime_opengl
            app.loadBackend(new LimeBackend(context.gl, app.displayWidth, app.displayHeight));
            #elseif lime_webgl
            app.loadBackend(new LimeBackend(context.webgl2, app.displayWidth, app.displayHeight));
            #elseif lime_opengles
            app.loadBackend(new LimeBackend(context.webgl2, app.displayWidth, app.displayHeight));
            #end

            
            // app.displayWidth = Std.int(1080);   // @todo width, height?
            // app.displayHeight = Std.int(2220);
            // trace("--------------------------------------------", window.display.bounds.size.x, window.display.bounds.size.y, window.display.bounds.width, window.display.bounds.height);
            app.w = window.width;
            app.h = window.height;
            app.isLoaded = true;
        }
        
        #if lime_opengl
        app.render(context.gl);
        #elseif lime_webgl
        app.render(context.webgl2);
        #elseif lime_opengles
        app.render(context.gles3);
        #end

        // @todo перенести
        var mouse = app?.backend?.mouse(0);
        if (mouse == null) return;
        mouse.wheelDeltaX = 0;
        mouse.wheelDeltaY = 0;
    }

    // window create, window restore

    override function update(deltaTime:Int) {
        // var mouse = app?.backend?.mouse(0);
        // mouse.x = mo.x;
        // mouse.y = mo.y;
        app?.update(deltaTime / 1000);
    }

    override function onWindowResize(width:Int, height:Int) {
        if (app == null) return;
        app.windowResize(width, height);
        if (Std.int(window.display.bounds.width) != app.displayWidth || Std.int(window.display.bounds.height) != app.displayHeight) {
            app.displayResize(Std.int(window.display.bounds.width), Std.int(window.display.bounds.height));
        }
    }

    override function onMouseDown(x:Float, y:Float, button:MouseButton) {
        app.backend.input(0).press(Button(Left));
        var mouse = app?.backend?.mouse(0);
        if (mouse == null) return;
        mouse.x = x;
        mouse.y = y;
        switch (button) {
            case LEFT: mouse.isLeftDown = true;
            case RIGHT: mouse.isRightDown = true;
            case MIDDLE: mouse.isMiddleDown = true;
        }
    }

    override function onMouseUp(x:Float, y:Float, button:MouseButton) {
        app.backend.input(0).release(Button(Left));
        var mouse = app?.backend?.mouse(0);
        if (mouse == null) return;
        mouse.x = x;
        mouse.y = y;
        switch (button) {
            case LEFT: mouse.isLeftDown = false;
            case RIGHT: mouse.isRightDown = false;
            case MIDDLE: mouse.isMiddleDown = false;
        }
    }

    // var mo = new Vector();
    override function onMouseMove(x:Float, y:Float) {
        var mouse = app?.backend?.mouse(0);
        if (mouse == null) return;
        mouse.x = x;
        mouse.y = y;
        // mo.set(x, y);
    }

    override function onMouseWheel(deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode) {
        var mouse = app?.backend?.mouse(0);
        if (mouse == null) return;
        #if desktop
        mouse.wheelDeltaX = deltaX;
        mouse.wheelDeltaY = deltaY;
        #else
        mouse.wheelDeltaX = deltaX / 100.0;
        mouse.wheelDeltaY = deltaY / 100.0;
        #end
    }

    override function onTouchStart(touch:Touch) {
        touches.push(touch);
        trace("a");
    }

    override function onTouchEnd(touch:Touch) {
        var touch = touches.find(t -> t.id == touch.id);
        touches.remove(touch);
    }

    override function onTouchMove(touch:Touch) {
        var mouse = app?.backend?.mouse(0);
        if (mouse == null) return;
        if (touches.length == 2) {
            var first = touches.find(t -> t.id != touch.id);
            mouse.wheelDeltaX = (touch.x > first.x ? touch.dx : -touch.dx) * 50.0;
            mouse.wheelDeltaY = (touch.y > first.y ? touch.dy : -touch.dy) * 50.0;
        }
    }

    override function onKeyDown(keyCode:KeyCode, modifier:KeyModifier) {
        app.backend.input(0).press(KeyCode(mapKey(keyCode)));
    }

    override function onKeyUp(keyCode:KeyCode, modifier:KeyModifier) {
        app.backend.input(0).release(KeyCode(mapKey(keyCode)));
    }

    override function onTextInput(text:String) {
        // @todo как понять когда поднята клавиша? - на слеющей итерации обнулять?
        app.backend.input(0).press(Char(text));
    }

    function mapKey(src:KeyCode):crovown.types.Action.KeyCode {
        return switch (src) {
            case LEFT_CTRL | RIGHT_CTRL: Ctrl;
            case LEFT_SHIFT | RIGHT_SHIFT: Shift;
            case LEFT_ALT | RIGHT_ALT: Alt;
            case RETURN: Return;
            case BACKSPACE: Backspace;
            case DELETE: Delete;
            case TAB: Tab;
            case ESCAPE: Escape;
            case SPACE: Space;
            case PLUS | NUMPAD_PLUS: Plus;
            case MINUS | NUMPAD_MINUS: Minus;
            case LEFT: Left;
            case RIGHT: Right;
            case UP: Up;
            case DOWN: Down;
            case A: A;
            case B: B;
            case C: C;
            case D: D;
            case E: E;
            case F: F;
            case G: G;
            case H: H;
            case I: I;
            case J: J;
            case K: K;
            case L: L;
            case M: M;
            case N: N;
            case O: O;
            case P: P;
            case Q: Q;
            case R: R;
            case S: S;
            case T: T;
            case U: U;
            case V: V;
            case W: W;
            case X: X;
            case Y: Y;
            case Z: Z;
            default: Unknown;
        }
    }
}