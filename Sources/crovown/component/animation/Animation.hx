package crovown.component.animation;

import crovown.ds.Signal.Slot;
import crovown.types.Kind;

using Lambda;

// @todo add events?

@:build(crovown.Macro.component(false))
class Animation extends Component {
    @:p public var duration:Float = 10.0;
    @:p public var isLooped:Bool = false;
    @:p public var speed:Float = 1.0;
    @:p public var offset:Float = 0.0;
    @:p public var isFreezed:Bool = false;
    @:p public var easing:Float->Float = null;

    public var elapsed = 0.0;
    public var isPlaying = false;
    public var progress(get, never):Float;
    inline function get_progress() {
        return easing == null ? elapsed / duration : easing(elapsed / duration);
    }

    // Callbacks
    @:p public var onFrameChanged:Animation->Float->Void = null;
    @:p public var onStart:Animation->Void = null;
    @:p public var onEnd:Animation->Void = null;

    public var data:Component = null;

    var slot:Slot<Float->Void> = null;

    public function new() {
        super();
        kind = Kind.Animation;
    }

    public static function build(crow:Crovown, component:Animation) {
        return component;
    }

    override public function dispose() {
        
    }

    public function setFrame(frame:Float) {
        elapsed = frame;
        if (isLooped) elapsed = Math.max(elapsed % duration, offset);
        if (elapsed > duration) return false;
        if (onFrameChanged != null) onFrameChanged(this, progress);
        return true;
    }

    public function play(crow:Crovown) {
        stop(crow);
        isPlaying = true;
        if (onStart != null) onStart(this);
        elapsed = offset;
        slot = crow.application.onUpdate.subscribe(Std.string(id), deltaTime -> {
            if (isFreezed) return;
            if (!setFrame(elapsed + deltaTime * speed)) {
                elapsed = duration;
                if (onFrameChanged != null) onFrameChanged(this, progress);
                stop(crow);
            }
        });
        return this;
    }

    public function stop(crow:Crovown) {
        slot?.unsubscribe();
        slot = null;
        if (!isPlaying) return this;
        isPlaying = false;
        crow.application.onUpdate.unsubscribeBy(Std.string(id));
        if (onEnd != null) onEnd(this);
        return this;
    }
}