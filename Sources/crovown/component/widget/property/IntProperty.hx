package crovown.component.widget.property;

using crovown.component.widget.LayoutWidget;
using crovown.component.widget.TextWidget;

@:build(crovown.Macro.component(false))
class IntProperty extends Property {
    @:p public var onChange:Float->Void;
    @:p public var onFinished:Float->Void;
    @:p public var step:Float = 0.1;
    @:p public var round:Int = 10;
    @:p public var value:Float = 1.0;

    public static function build(crow:Crovown, component:IntProperty) {
        component.onInput = event -> {
            var area = component.getArea();
            if (area.isPressed) {
                component.isActive = true;
            }
            return true;
        }
        component.color = Color(Transparent);
        component.vertical = Hug;
        component.gap = Fixed(6);
        component.children = [
            crow.TextWidget(text -> {
                text.text = '${component.name}:';
                // text.history = false;
            }),
            crow.LayoutWidget(layout -> {
                layout.label = "control";
                layout.onInput = event -> {
                    var area = layout.getArea();
                    if (area.isPressed) {
                        component.value -= component.step;
                        component.onChange(component.value);
                    }
                    return true;
                }
            }, [
                crow.TextWidget(text -> {
                    text.text = "<";
                })
            ]),
            crow.LayoutWidget(layout -> {
                layout.label = "input-box";
            }, [
                crow.TextWidget(text -> {
                    text.onInput = event -> {
                        // if (component.isActive) {
                            
                        // }
                        text.text = '${Math.round(component.value * component.round) / component.round}';
                        return true;
                    }
                })
            ]),
            crow.LayoutWidget(layout -> {
                layout.label = "control";
                layout.onInput = event -> {
                    var area = layout.getArea();
                    if (area.isPressed) {
                        component.value += component.step;
                        component.onChange(component.value);
                    }
                    return true;
                }
            }, [
                crow.TextWidget(text -> {
                    text.text = ">";
                })
            ]),
        ];

        // component.children = [
        //     crow.TextWidget(text -> {
        //         text.text = '${component.name}:';
        //     }),
        //     crow.LayoutWidget(layout -> {
        //         layout.label = "input-box";
        //     }, [
        //         crow.TextWidget(text -> {
        //             text.label = "selected";
        //             text.text = "<";
        //         }),
        //         crow.TextWidget(text -> {
        //             text.onInput = event -> {
        //                 if (component.isActive) {
                            
        //                 }
        //                 return true;
        //             }
        //         }),
        //         crow.TextWidget(text -> {
        //             text.label = "selected";
        //             text.text = ">";
        //         })
        //     ])
        // ];
        return component;
    }
}