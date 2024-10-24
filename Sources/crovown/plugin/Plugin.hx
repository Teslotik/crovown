package crovown.plugin;

import crovown.ds.Signal;

@:build(crovown.Macro.plugin())
class Plugin {
    public static final factory = new Map<String, Crovown->Plugin>();
    
    public var label(default, null):String = null;
    
    public var isAutoLoadable = false;
    public var isEnabled = false;
    public var crow:Crovown = null;

    public var onCreated = new Signal<Plugin->Void>();
    public var onEnabled = new Signal<Plugin->Void>();
    public var onDisabled = new Signal<Plugin->Void>();

    public function new() {
        label = "Plugin";
    }

    public function onCreate(crow:Crovown) {}
    public function onEnable(crow:Crovown) {}
    public function onDisable(crow:Crovown) {}
    public function onCrash(crow:Crovown) {}    // @todo

    public final function enable(crow:Crovown) {
        try {
            onEnable(crow);
            onEnabled.emit(slot -> slot(this));
            isEnabled = true;
            return true;
        } catch (e) {
            Crovown.onPluginException.emit(slot -> slot(this, label, e));
        }
        return false;
    }

    public final function disable(crow:Crovown) {
        try {
            onDisable(crow);
            onDisabled.emit(slot -> slot(this));
            isEnabled = false;
            return true;
        } catch (e) {
            Crovown.onPluginException.emit(slot -> slot(this, label, e));
        }
        return false;
    }
}