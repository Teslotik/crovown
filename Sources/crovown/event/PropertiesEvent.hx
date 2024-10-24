package crovown.event;

import crovown.ds.Signal;

using crovown.component.widget.SpacerWidget;
using crovown.component.widget.LayoutWidget;
using crovown.component.widget.TextWidget;

@:build(crovown.Macro.event())
class PropertiesEvent extends Event {
    public var layout:LayoutWidget = null;
    public var panel:LayoutWidget = null;

    var crow:Crovown = null;

    public function new(crow:Crovown, panel:LayoutWidget) {
        super();
        this.panel = panel;
        this.crow = crow;
    }

    public function group(title:String) {
        panel.addChild(layout = crow.LayoutWidget(layout -> {
            layout.label = "group";
        }, [
            crow.TextWidget(text -> {
                text.text = title;
                text.align = -1;
            })
        ]));
        panel.addChild(crow.SpacerWidget());
    }
}