package crovown.event;

import crovown.component.Component;

@:build(crovown.Macro.event())
class Event {
    public var isCancelled = false;
    public var isSkip = false;

    public function new() {
        
    }

    // public function onNext(component:Component) {}
    // public function onPost(component:Component) {}
    public function onForward(component:Component) {}
    public function onBackward(component:Component) {}
}