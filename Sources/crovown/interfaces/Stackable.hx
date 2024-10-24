package crovown.interfaces;

interface Stackable<T> {
    var top(get, null):T;
    public function push(v:Null<T>):Void;
    public function pop():Null<T>;
    public function clear():Void;
}