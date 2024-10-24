package crovown.component;

import crovown.ds.Signal;

@:build(crovown.Macro.component())
class RegistryComponent extends Component {
    public var collection = new Map<String, Void->Component>();
    public var onAdd = new Signal<(RegistryComponent, String, Void->Component)->Void>();
    public var onRemove = new Signal<(RegistryComponent, String)->Void>();

    public static function build(crow:Crovown, component:RegistryComponent) {
        return component;
    }

    public function getCallbacks() {
        return collection.iterator();
    }

    public function getItems() {
        return collection.keys();
    }

    public function subscribe(label:String, callback:Void->Component) {
        collection.set(label, callback);
        onAdd.emit(slot -> slot(this, label, callback));
        return this;
    }

    public function unsubscribe(label:String) {
        collection.remove(label);
        onRemove.emit(slot -> slot(this, label));
        return this;
    }

    public function emit(label:String) {
        return collection.get(label)();
    }
}