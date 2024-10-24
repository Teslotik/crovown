package crovown;

import crovown.application.Application;
import crovown.component.Component;
import crovown.ds.Signal;
import crovown.plugin.Plugin;
import haxe.Exception;

using Lambda;

typedef After = {
    label:String,
    callback:Component->Void,
    isResolved:Bool
}

typedef Rule = {
    var apply:Component->Void;
}

typedef Action = {
    label:String,
    apply:Crovown->Void,
    revert:Crovown->Void
}

// @todo повыносить отсда в ApplicationComponent
@:build(crovown.Macro.buildinfo())
final class Crovown {
    // Current state
    public static var active:Component = null;  // @note is not used yet, feel freee to assign your own components here
    public var application:Application = null;

    public var delayed = new Array<After>();    // @todo оставить либо здесь, либо в Application
    public var plugins = new Array<Plugin>();
    public var tags = new List<String>();
    public var props = new Map<String, Dynamic>();

    // Listeners
    public var rules = new Array<Rule>();
    public var history = {
        capacity: 10,
        // New actions will appear at the start of the list
        forward: new List<Action>(),
        backward: new List<Action>()
    }
    
    // Callbacks

    // Signals
    public static final onUndo = new Signal<Action->Void>();
    public static final onRedo = new Signal<Action->Void>();
    public static final onTagAdd = new Signal<String->Void>();
    public static final onTagRemove = new Signal<String->Void>();
    public static final onPropAdd = new Signal<String->Dynamic->Void>();
    public static final onPropRemove = new Signal<String->Void>();
    public static final onPluginException = new Signal<Plugin->String->Exception->Void>();

    public var isHistoryLocked(default, default):Bool = false;

    public function new(app:Application) {
        application = app;
        Component.onRule.subscribe(component -> {
            for (rule in rules) rule.apply(component);
        });
        Component.onBuild.subscribe(component -> {
            var wasResolved = false;
            for (d in delayed) {
                if (d.label != component.label) continue;
                d.callback(component);
                wasResolved = true;
            }
            if (wasResolved)
                delayed = delayed.filter(a -> !a.isResolved);
        });

        // Plugins
        onPluginException.subscribe("crovown", (plugin, code, e) -> {
            trace("[ERROR] Exception in plugin: " + code);
            trace(e.message);
            trace(e.stack);
        });
        // Instantialting all plugins from factory
        for (item in Plugin.factory.keyValueIterator()) {
            var plugin = item.value(this);
            if (plugin == null) continue;
            trace("Plugin loaded: " + plugin.label);
            plugins.push(plugin);
        }
        // Enabling plugins
        for (plugin in plugins) {
            if (!plugin.isAutoLoadable || !plugin.enable(this)) continue;
            trace("Plugin enabled: " + plugin.label);
        }
    }

    // Вызывается после создания компонента (или родства?)
    public function after(label:String, callback:Component->Void) {
        delayed.push({
            label: label,
            callback: callback,
            isResolved: false
        });
        return this;
    }

    public function rule(apply:Component->Void) {
        rules.push({
            apply: apply
        });
        return this;
    }

    public function removeRule(apply:Component->Void) {
        rules.remove(rules.find(rule -> rule.apply == apply));
        return this;
    }

    // @todo записывает полное состоние дерева (вместо undo и redo)
    public function record(label:String, apply:Crovown->Void, revert:Crovown->Void) {
        if (isHistoryLocked) return this;
        if (history.forward.length > history.capacity) history.forward.pop();
        history.backward.clear();
        history.forward.add({
            label: label,
            apply: apply,
            revert: revert
        });
        return this;
    }

    public function undo(steps:Int, ?f:Action->Bool) {
        isHistoryLocked = true;
        var step = 0;
        var current:Action = null;
        while (history.forward.length > 0) {
            if (step >= steps) break;
            current = history.forward.last();
            history.forward.remove(current);
            if (f == null || f(current)) {
                current.revert(this);
                step++;
                onUndo.emit(slot -> slot(current));
            }
            history.backward.add(current);
        }
        isHistoryLocked = false;
        return this;
    }

    public function redo(steps:Int, ?f:Action->Bool) {
        isHistoryLocked = true;
        var step = 0;
        var current:Action = null;
        while (history.backward.length > 0) {
            if (step >= steps) break;
            current = history.backward.last();
            history.backward.remove(current);
            if (f == null || f(current)) {
                current.apply(this);
                step++;
                onRedo.emit(slot -> slot(current));
            }
            history.forward.add(current);
        }
        isHistoryLocked = false;
        return this;
    }

    // public function redo(label:String, ?filter:Action->Bool) {
    //     var current = history.backward.pop();
    //     while (current != null) {
    //         if (filter == null || filter(current)) current.apply(this);
    //         history.forward.push(current);
    //         if (current.label == label) return this;
    //         current = history.backward.pop();
    //     }
    //     return this;
    // }

    // ----------------------------- Properties -----------------------------

    public inline function setProp(label:String, value:Dynamic) {
        props.set(label, value);
        onPropAdd.emit(slot -> slot(label, value));
        return this;
    }

    public inline function getProp(label:String, ?fallback:Dynamic) {
        if (props == null) return null;
        if (!props.exists(label)) return fallback;
        return props.get(label);
    }

    public inline function hasProp(label:String) {
        return props.exists(label);
    }

    public inline function removeProp(label:String) {
        props.remove(label);
        onPropRemove.emit(slot -> slot(label));
        return this;
    }

    public inline function addTag(tag:String) {
        tags.add(tag);
        onTagAdd.emit(slot -> slot(tag));
        return this;
    }

    public inline function hasTag(tag:String) {
        return tags.has(tag);
    }
    
    public inline function removeTag(tag:String) {
        tags.remove(tag);
        onTagRemove.emit(slot -> slot(tag));
        return this;
    }
}