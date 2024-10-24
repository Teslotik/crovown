package crovown.component;

import crovown.event.ValidateEvent;
import crovown.event.GizmoEvent;
import crovown.event.PropertiesEvent;
import crovown.event.Event;
import haxe.ds.Option;
import haxe.io.Bytes;
import crovown.algorithm.MathUtils;
import crovown.application.Application;
import crovown.ds.Signal;
import crovown.types.Kind;
import crovown.component.animation.Animation;
import crovown.ds.Info;

using Lambda;

class DfsIterator {
    public var queue = new List<Component>();

    public function new(?origin:Component) {
        if (origin != null) queue.push(origin);
    }
    
    // @todo
    // public function new(?origin:Component, forward = true, reverse = false) {}

    public function hasNext():Bool {
        // return queue.first() != null;    // @todo
        return !queue.isEmpty();
    }

    public function next():Component {
        var current = queue.pop();
        for (i in 0...current.children.length) {
            queue.push(current.children[current.children.length - i - 1]);
        }
        return current;
    }
}

@:build(crovown.Macro.component())
class Component {
    public static final factory = new Map<String, Info>();

    // Id
    // You can consider ids as a pointers in c++, however in Crovown it is a random number
    // If you need to associate two components, you can modify this number as you wish
    @:p public var id:Int = 0;
    @:p public var label:String = "";
    @:p public var url:String = "";     // unique path, useful to acces to the component in a tree
    public var kind:Kind = Kind.Component;
    @:p public var tags:List<String> = null;
    @:p public var props:Map<String, Dynamic> = null;

    // @todo Add editor info

    // State
    public var builder:Component->Void = null;
    @:p public var isEnabled:Bool = true;
    @:p public var isActive:Bool = false;
    public var isDirty = true;
    public var crow:Crovown = null; // Crovown instance used during component building
    public var isBuilded = false;

    // Hierarchy
    public var parent(default, set):Component = null;
    function set_parent(v:Component):Component {
        if (v == null) {
            parent?.children.remove(this);
            parent = null;
            onUnparent.emit(slot -> slot(this));
            return v;
        }
        if (!canParent(v)) return null;
        parent = v;
        onParent.emit(slot -> slot(this));
        return v;
    }

    @:p public var children(default, set):Array<Component> = new Array<Component>();
    function set_children(v:Array<Component>):Array<Component> {
        if (children != null) {
            while (children.length > 0) removeChild(children[0]); // @todo с конца?
        }
        for (child in v) addChild(child);
        return children;
    }

    // Parallel hierarchy
    @:p public var animation:Animation = null;

    // Callbacks
    @:p public var onRebuild:Component->Void = null;
    // @:p public var onAfterChild:Component->Void = null;  // @todo
    @:p public var onCreate:Component->Void = null;
    @:p public var onReady:Component->Void = null;
    @:p public var onDestroy:Component->Void = null;

    // Events
    private final handlers = new Map<Int, Event->Void>();

    // Signals
    static public final onRule = new Signal<Component->Void>();
    static public final onBuild = new Signal<Component->Void>();
    static public final onParent = new Signal<Component->Void>();
    // static public final afterChild = new Signal<Component->Void>();  // @todo
    static public final onUnparent = new Signal<Component->Void>();
    static public final onTagAdd = new Signal<Component->String->Void>();
    static public final onTagRemove = new Signal<Component->String->Void>();
    static public final onPropAdd = new Signal<Component->String->Dynamic->Void>();
    static public final onPropRemove = new Signal<Component->String->Void>();

    public function new() {
        id = MathUtils.randrange(0, Std.int(2e31));
        registerHandlers();
    }

    public static function build(crow:Crovown, component:Component) {
        return component;
    }

    public function free() {
        if (true) {
            // for (child in children) child.free();
            while (children.length > 0) children[children.length - 1].free();
        }
        tags?.clear();
        props?.clear();
        tags = null;
        props = null;
        parent = null;
    }

    // @note Should we lock history?
    public function dispose() {
        animation?.dispose();
    }
    
    // @todo пересмотреть необходимость в этих двух методах
    public function invalidate() {
        isDirty = true;
    }

    public function validate() {
        isDirty = false;
    }

    public function toString() {
        return '{id: ${id}, label: ${label}, url: ${url}, kind: ${kind}, type: ${getType()}}';
    }

    public function printTree(depth = 0) {
        var padding = [for (i in 0...depth) "    "].join("");
        // return padding + '{id: ${id}, label: ${label}, url: ${url}, kind: ${kind}, type: ${type}, animation:\n${animation?.printTree(depth + 1)}, children: ${[for (c in children) "\n" + c.printTree(depth + 1)]}}';
        // + getType()
        return '${padding}{id: ${id}, label: ${label}, url: ${url}, kind: ${kind}, type: ${getType()}, animation: ${animation == null ? null : "\n" + animation.printTree(depth + 1)}, children: [\n${[for (c in children) c.printTree(depth + 1)].join(",\n")}\n${padding}]}';
    }

    inline function getCode() {
        return code;
    }

    // ----------------------------- Editor -----------------------------

    // Analyse tree to check for mistakes
    @:eventHandler
    function onValidateEvent(event:ValidateEvent) {
        
    }

    @:eventHandler
    function onPropertiesEvent(event:PropertiesEvent) {
        
    }

    @:eventHandler
    function onGizmoEvent(event:GizmoEvent) {
        
    }

    // ----------------------------- Iterators -----------------------------

    public function iterator():Iterator<Component> {
        return new DfsIterator(this);
    }

    public function dfs(self = true):Iterator<Component> {
        // return new DfsIterator(self ? this : parent);   // @todo убрать условие в скобках
        if (self) return new DfsIterator(this);
        var it = new DfsIterator();
        for (child in children) it.queue.add(child);
        return it;
    }

    public function apply(?pre:Component->Void, ?post:Component->Void, self = true) {
        if (pre != null && self) pre(this);
        for (child in children) child.apply(pre, post);
        if (post != null && self) post(this);
        return this;
    }

    // public function applyTo(?pre:Component->Bool, ?post:Component->Bool, self = true) {
    //     if (pre != null && self) {
    //         if (!pre(this)) return this;
    //     }
    //     for (child in children) child.applyTo(pre, post);
    //     if (post != null && self) {
    //         if (!post(this)) return this;
    //     }
    //     return this;
    // }

    public function applyTo(?pre:Component->Bool, ?post:Component->Bool, self = true) {
        if (pre != null && self) {
            if (!pre(this)) return false;
        }
        for (child in children) {
            if (!child.applyTo(pre, post)) return false;
        }
        if (post != null && self) {
            if (!post(this)) return false;
        }
        return true;
    }

    public function dispatch(event:Event, self = true, forward = true, reversed = false) {
        if (event.isCancelled) return;
        var handler = handlers.get(event.getHash());
        if (forward) {
            // @todo unite conditions
            if (self) {
                if (handler != null) {
                    event.onForward(this);
                    // event.onNext(this);
                    if (!event.isCancelled) handler(event);
                    // event.onPost(this);
                }
            }
            if (reversed) {
                for (i in 0...children.length) children[children.length - i - 1].dispatch(event, true, forward, reversed);
            } else {
                for (child in children) child.dispatch(event, true, forward, reversed);
            }
            if (self && handler != null) {
                event.onBackward(this);
            }
        } else {
            event.onForward(this);
            if (reversed) {
                for (i in 0...children.length) children[children.length - i - 1].dispatch(event, true, forward, reversed);
            } else {
                for (child in children) child.dispatch(event, true, forward, reversed);
            }
            if (self) {
                if (handler != null) {
                    // event.onNext(this);
                    if (!event.isCancelled) handler(event);
                    // event.onPost(this);
                    event.onBackward(this);
                }
            }
        }
    }

    // ----------------------------- Serialization and synchronization -----------------------------

    // User defined serialization
    public function toStruct():Null<Dynamic> {
        return null;
    }

    public static function fromStruct(v:Dynamic) {
        
    }

    // public function simplify(name:String):Option<Dynamic> {
    //     // if (variable == "children") {
    //     //     // return Some([for (c in children) c.label]);
    //     //     return Some([for (c in children) c.store()]);
    //     // } else if (variable == "animation") {
    //     //     trace("==== storing animation");
    //     //     return Some(animation.store());
    //     // }

    //     return None;
    // }

    public function serialize(name:String):Option<Dynamic> {
        return None;
    }

    public function deserialize(name:String, v:Dynamic) {
        
    }
    
    // @todo с точками и при параллельной иерархии указывается название переменной, а не label
    // @note или полный путь должен генерироваться в другой функции?
    public function makePath(label:String, ?root:String) {
        var path = label;
        var current = parent;
        while (current != null && current.label != root) {
            path = current.label + "/" + path;
            current = current.parent;
        }
        if (root != null) return root + "/" + path;
        return path;
    }

    // tree
    function sync<T:Component>(crow:Crovown, src:Component, dst:Component, builder:T->Component, compare:Component->Component->Bool) {
        for (i in 0...src.children.length) {
            var a = src.children[i];
            if (dst.children.length <= i || !compare(dst.children[i], a)) {
                dst.insertChild(i, builder(cast a));
            }
        }
        while (dst.children.length > src.children.length) {
            dst.removeChild(dst.children[dst.children.length - 1]);
        }
        for (i in 0...src.children.length) {
            sync(crow, src.children[i], dst.children[i], builder, compare);
        }
    }
    public function synchronize<T:Component>(crow:Crovown, model:Component, builder:T->Component, ?compare:Component->Component->Bool) {
        sync(crow, model, this, builder, compare ?? (a, b) -> a.label == b.label);
    }

    // ----------------------------- Hierarchy -----------------------------

    // public function canChild(component:Component) {
    //     return true;
    // }

    // public function canParent(component:Component) {
    //     return true;
    // }

    public function isParent(component:Component) {
        var current = this.parent;
        while (current != null) {
            if (current == component) return true;
            current = current.parent;
        }
        return false;
    }

    public function addChild(child:Component) {
        if (child == null) return this;
        if (!canChild(child)) return this;
        children.push(child);
        child.parent = this;
        return this;
    }

    public function insertChild(pos = 0, child:Component) {
        if (child == null) return this;
        if (!canChild(child)) return this;
        child.parent = null;
        children.insert(pos, child);
        child.parent = this;
        return this;
    }

    public function addChildSorted(child:Component, f:(item:Component, result:Component)->Component) {
        if (child == null) return this;
        if (!canChild(child)) return this;
        // @todo
        return this;
    }

    public function getChildAt<T:Component>(index:Int):T {
        if (index < 0 || index >= children.length) return null;
        return cast children[index];
    }

    public function getChildBy<T:Component>(f:Component->Bool):T {
        return cast children.find(f);
    }

    public function getChildFirst<T:Component>():T {
        return cast(children.length == 0 ? null : children[0]);
    }

    public function getChildLast<T:Component>():T {
        return cast(children.length == 0 ? null : children[children.length - 1]);
    }

    public function getChildIndex(child:Component):Null<Int> {
        var index = children.indexOf(child);
        return index == -1 ? null : index;
    }

    public function removeChild(child:Component) {
        if (child == null) return this;
        child.parent = null;
        return this;
    }

    // @todo в remove возвращать ребёнка
    public function removeChildAt(index:Int) {
        if (index < 0 || index >= children.length) return this;
        removeChild(children[index]);
        return this;
    }

    public function removeChildBy(f:Component->Bool) {
        removeChild(children.find(f));
        return this;
    }

    public function removeChildren() {
        while (children.length > 0) removeChild(children[0]);
        return this;
    }

    public function removeAfterIndex(index:Int) {
        index++;
        while (children.length > index) removeChild(children[index]);
        return this;
    }

    public function removeAfter(component:Component) {
        var index = children.indexOf(component);
        if (index == -1) return this;
        removeAfterIndex(index);
        return this;
    }

    public function moveChild(pos:Int, child:Component) {
        var index = children.indexOf(child);
        if (index == -1) {
            return this;
        } else if (index > pos) {
            children.remove(child);
            children.insert(pos, child);
        } else if (index < pos) {
            children.remove(child);
            children.insert(pos - 1, child);
        }
        return this;
    }

    // @todo проверить
    public function replaceChild(src:Component, dst:Component) {
        var index = children.indexOf(src);
        return replaceChildAt(index, dst);
    }

    public function replaceChildAt(index:Int, dst:Component) {
        // removeChild(src);
        // insertChild(index, dst);
        var src = children[index];
        children[index] = dst;
        src.parent = null;
        dst.parent = this;
        return this;
    }

    public function replace(other:Component) {
        var parent = this.parent;
        var index = parent.children.indexOf(this);
        this.parent = null;
        parent.insertChild(index, other);
        return this;
    }

    public final function getParent<T:Component>():T {
        return cast(parent);
    }
    
    public final function getParentBy<T:Component>(f:Component->Bool):T {
        var current = parent;
        while (current != null) {
            if (f(current)) return cast current;
            current = current.parent;
        }
        return null;
    }

    public final function getChildren<T:Component>():Array<T> {
        return cast(children);
    }

    public final function getAnimation<T:Animation>():T {
        return cast animation;
    }

    // ----------------------------- Search -----------------------------

    public final function getRoot() {
        var current = this;
        while (true) {
            if (current.parent == null) return current;
            current = current.parent;
        }
        return null;
    }

    public function getOrigin<T:Component>():T {
        var current = this;
        while (current.parent != null) {
            if (current.parent.kind != current.kind) return cast current;
            current = current.parent;
        }
        return cast current;
    }

    public final function getApplication() {
        var current = this;
        while (current != null) {
            if (current.kind == Application) return cast(current, Application);
            current = current.parent;
        }
        return null;
    }

    public final function getDepth(label:String, self = true) {
        var depth = 0;
        var current = self ? this : parent;
        while (current != null) {
            if (current.label == label) break;
            current = current.parent;
            depth++;
        }
        return depth;
    }
    
    public final function getDepthBy(f:Component->Bool, self = true) {
        var depth = 0;
        var current = self ? this : parent;
        while (current != null) {
            if (f(current)) break;
            current = current.parent;
            depth++;
        }
        return depth;
    }

    // @todo test
    public function getPath(label:String) {
        var path = this.label;
        var current = this;
        while (current != null && current.label != label) {
            current = current.parent;
            path += "/" + current.label;
        }
        return path;
    }

    // @todo test
    public function getPathBy(f:Component->Bool) {
        var path = label;
        var current = this;
        while (current != null && !f(current)) {
            current = current.parent;
            path += "/" + current.label;
        }
        return path;
    }

    public final function search<T:Component>(label:String):T {
        // BFS
        var queue = new List<Component>();
        queue.add(this);
        while (!queue.empty()) {
            var current = queue.pop();
            if (current.label == label) return cast current;
            for (child in current.children) queue.add(child);
        }
        return null;
    }

    public final function searchBy<T:Component>(f:Component->Bool):T {
        return cast Lambda.find(this, f);
    }

    public final function find<T:Component>(path:String):T {
        var current = this;
        for (component in path.split("/")) {
            var up = 0;
            while (up < component.length && component.charAt(up) == ".") {
                up++;
                current = current.parent;
                if (current == null) return null;
            }
            if (up > 0) continue;
            if (current.children.empty()) return null;
            current = if (component == "") current.children[0] else current.children.find(c -> c.label == component);
            if (current == null) return null;
        }
        return cast current;
    }

    public final function get<T:Component>(url:String):T {
        var found:Component = null;
        applyTo(component -> {
            if (component.url != url) return true;
            found = component;
            return false;
        });
        return cast found;
    }

    // public function countTo(f:Component->Void) {
        
    // }

    // ----------------------------- Properties -----------------------------
    
    inline public final function setProp(label:String, value:Dynamic) {
        props ??= new Map<String, Dynamic>();
        props.set(label, value);
        onPropAdd.emit(slot -> slot(this, label, value));
        return this;
    }

    inline public final function getProp(label:String, ?fallback:Dynamic) {
        if (props == null) return null;
        if (!props.exists(label)) return fallback;
        return props.get(label);
    }

    inline public final function hasProp(label:String) {
        if (props != null) return props.exists(label);
        return false;
    }

    inline public final function removeProp(label:String) {
        if (props != null) props.remove(label);
        onPropRemove.emit(slot -> slot(this, label));
        return this;
    }

    inline public final function addTag(tag:String) {
        if (tags == null) tags = new List<String>();
        tags.add(tag);
        onTagAdd.emit(slot -> slot(this, tag));
        return this;
    }

    inline public final function hasTag(tag:String) {
        if (tags != null) return tags.has(tag);
        return false;
    }
    
    inline public final function removeTag(tag:String) {
        if (tags != null) tags.remove(tag);
        onTagRemove.emit(slot -> slot(this, tag));
        return this;
    }
}