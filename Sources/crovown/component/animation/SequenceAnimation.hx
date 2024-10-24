package crovown.component.animation;

@:build(crovown.Macro.component(false))
class SequenceAnimation extends Animation {
    public var active:Animation = null;

    public static function build(crow:Crovown, component:SequenceAnimation) {
        return component;
    }

    override public function setFrame(frame:Float):Bool {
        elapsed = frame;
        if (isLooped) {
            var children:Array<Animation> = getChildren();
            for (child in children) child.elapsed = offset;
            elapsed = Math.max(elapsed % duration, offset);
        }
        if (elapsed > duration) return false;
        if (onFrameChanged != null) onFrameChanged(this, progress);

        var children:Array<Animation> = getChildren();
        var total = 0.0;
        for (child in children) {
            active = child;
            if (total + child.duration < elapsed) {
                total += child.duration;
                child.elapsed = child.duration;
            } else {
                break;
            }
        }
        active.setFrame(elapsed - total);

        return true;
    }

    override public function play(crow:Crovown) {
        stop(crow);
        isPlaying = true;
        if (onStart != null) onStart(this);
        
        var children:Array<Animation> = getChildren();
        for (child in children) child.elapsed = child.offset;

        if (children.length == 0) return this;
        
        active = children[0];

        elapsed = offset;
        slot = crow.application.onUpdate.subscribe(Std.string(id), deltaTime -> {
            if (isFreezed) return;

            if (!setFrame(elapsed + deltaTime * speed * active.speed)) {
                elapsed = duration;
                active.setFrame(active.duration);
                if (onFrameChanged != null) onFrameChanged(this, progress);
                stop(crow);
            }
        });

        return this;
    }

    override public function stop(crow:Crovown) {
        slot?.unsubscribe();
        slot = null;
        if (!isPlaying) return this;
        isPlaying = false;
        active?.stop(crow);
        active = null;
        crow.application.onUpdate.unsubscribeBy(Std.string(id));
        if (onEnd != null) onEnd(this);
        return this;
    }

    public function playAnimation(crow:Crovown, label:String) {
        // isPlaying = true;
        active?.stop(crow);
        active = find(label);
        active?.play(crow);
        return this;
    }

    public function updateDuration() {
        var children:Array<Animation> = getChildren();
        duration = 0;
        for (child in children) duration += child.duration;
        return this;
    }
}