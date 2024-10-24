package crovown.ds;

import crovown.component.Component;
import crovown.types.Priority;

using Lambda;

class Slot<F> {
    public var signal:Signal<F>;
    public var callback:F;
    public var label:String;
    public var component:Component;
    public var priority:Priority = Normal;
    public var isFreezed = false;

    public function new(signal:Signal<F>, callback:F, component:Component, label:String, priority:Priority, isFreezed:Bool) {
        this.signal = signal;
        this.callback = callback;
        this.component = component;
        this.priority = priority;
        this.label = label;
        this.isFreezed = isFreezed;
    }

    public function unsubscribe() return signal.unsubscribe(this);
}

class Signal<F> {
    public var slots = new Array<Slot<F>>();
    public var isSorted:Bool;
    public var stop = false;    // if true dispatching will be terminated in the next iteration
    public var sync = false;    // locks emit function till current is completed

    public function new(isSorted = false) {
        this.isSorted = isSorted;
    }

    public function iterator() {
        return slots.iterator();
    }

    public function subscribe(?component:Component, ?label:String, callback:F, priority:Priority = Normal, isFreezed = false) {
        var slot = new Slot<F>(this, callback, component, label, priority, isFreezed);
        slots.push(slot);
        if (isSorted) {
            slots.sort((a, b) -> b.priority - a.priority);
        }
        return slot;
    }

    public function unsubscribe(slot:Slot<F>) {
        slots.remove(slot);
        return this;
    }

    public function unsubscribeBy(?component:Component, ?label:String) {
        // slots = slots.filter(s -> s.label != label);
        slots = slots.filter(s -> (component == null || s.component != component) && (label == null || s.label != label));
        return this;
    }

    public function emit(?sync:Bool, handler:F->Void) {
        if (this.sync) return this;
        if (sync != null) this.sync = sync;
        for (slot in slots) {
            if (!slot.isFreezed) handler(slot.callback);
            if (stop) break;
        }
        stop = false;
        this.sync = false;
        return this;
    }

    public function setFreeze(label:String, v:Bool) {
        var slot = slots.find(s -> s.label == label);
        if (slot != null) slot.isFreezed = v;
        return this;
    }
}