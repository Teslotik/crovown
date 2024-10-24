package crovown.application;

import crovown.component.Component;
import crovown.ds.Signal;
import crovown.types.Priority;
import crovown.backend.Backend;
import crovown.backend.Backend.Surface;
import crovown.ds.Rectangle;

using Lambda;

typedef Promise = {
    poll:Application->Bool,
    callback:Application->Void,
    isResolved:Bool
}

typedef Delay = {
    component:Component,
    callback:Application->Void,
    depth:Int
}

class Application {
    public var title:String = "Crovown Application";
    public var w:Int = 1024;
    public var h:Int = 768;
    public var displayWidth:Int = 1920;
    public var displayHeight:Int = 1080;
    
    // State
    public var crow:Crovown = null;
    public var rectangle = new Rectangle();
    public var surface:Surface = null;
    public var backend:Backend = null;
    public var deltaTime = 0.0;
    public var isLoaded = false;
    public var isFullscreen = false;
    public var isMobile = false;
    public var isDesktop = false;
    public var framerate(get, set):Null<Float>;
    function get_framerate() return 30;
    function set_framerate(v:Null<Float>) return 30;
    public var dpi(get, never):Float;
    function get_dpi() return w / 2.54;

    // Collections
    public var promises = new Array<Promise>();
    public var delayed = new List<Application->Void>();
    public var delayedRelated = new Array<Delay>();

    // Signals
    public static var onDisplayResize = new Signal<Application->Int->Int->Void>();
    public static var onWindowResize = new Signal<Application->Int->Int->Void>();   // @todo pass window wrapper as an argument
    public var onUpdate = new Signal<Float->Void>(true);
    public var onFixedUpdate = new Signal<Float->Void>(true);
    public var onRender = new Signal<Application->Void>(true);

    // Callbacks
    @:p public var onLoad:Application->Void = null;
    
    public function new() {
        crow = new Crovown(this);
    }

    public function loadBackend(backend:Backend) {
        this.backend = backend;
        surface = backend.screenSurface(displayWidth, displayHeight);
        if (onLoad != null) onLoad(this);
    }

    public function minimize() {}
    public function maximize() {}
    public function fullscreen() {}
    public function stop() {}
    public function resize(w:Int, h:Int) {}  // @todo move to window class?

    public function update(deltaTime:Float) {
        this.deltaTime = deltaTime;
        
        while (!delayed.empty()) delayed.pop()(this);
        for (delayed in delayedRelated) {
            delayed.depth = delayed.component.getDepthBy(c -> false);
            delayed.component.isDirty = true;
        }
        delayedRelated.sort((a, b) -> a.depth - b.depth);
        for (delayed in delayedRelated) {
            if (!delayed.component.isDirty) continue;
            delayed.component.isDirty = false;
            delayed.callback(this);
        }

        onUpdate.emit(slot -> slot(deltaTime));
        // @todo replace polling in the loop to reacting on events
        var wasResolved = false;
        for (promise in promises) {
            if (!promise.poll(this)) continue;
            promise.callback(this);
            promise.isResolved = true;
            wasResolved = true;
        }
        if (wasResolved)
            promises = promises.filter(promise -> !promise.isResolved);
    }

    public function windowResize(w:Int, h:Int) {
        this.w = w;
        this.h = h;
        onWindowResize.emit(slot -> slot(this, w, h));
    }

    public function displayResize(w:Int, h:Int) {
        displayWidth = w;
        displayHeight = h;
        surface = backend.screenSurface(w, h);
        onDisplayResize.emit(slot -> slot(this, w, h));
    }

    public function copy(v:String) {
        
    }

    public function paste():String {
        return null;
    }

    public function promise(poll:Application->Bool, callback:Application->Void) {
        promises.push({
            poll: poll,
            callback: callback,
            isResolved: false
        });
        return this;
    }

    public function delay(f:Application->Void) {
        delayed.add(f);
        return this;
    }

    public function delayRelated(component:Component, f:Application->Void) {
        delayedRelated.push({
            component: component,
            callback: f,
            depth: 0
        });
        return this;
    }
}