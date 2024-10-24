package crovown.component.widget.property;

using crovown.component.widget.TextWidget;
using crovown.component.widget.LayoutWidget;

@:build(crovown.Macro.component(false))
class StringProperty extends Property {
    @:p public var onChange:String->Void;
    @:p public var onFinished:String->Void;

    public static function build(crow:Crovown, component:StringProperty) {
        component.onInput = event -> {
            var area = component.getArea();
            if (event.input.isPressed(Button(Left))) {
                component.isActive = area.isOver;
            }
            return true;
        }
        component.color = Color(Transparent);
        component.vertical = Hug;
        component.gap = Fixed(6);
        component.children = [
            crow.TextWidget(text -> {
                text.text = '${component.name}:';
            }),
            crow.LayoutWidget(layout -> {
                layout.label = "input-box";
            }, [
                crow.TextWidget(text -> {
                    text.onInput = event -> {
                        if (component.isActive) {
                            switch event.input.justPressed() {
                                case Char(v):
                                    // @todo вынести в свойства этого компонента
                                    text.text += v;
                                    component.onChange(text.text);
                                default:
                            }
                            if (event.input.isPressed(KeyCode(Backspace))) {
                                text.text = text.text.substr(0, text.text.length - 1);
                                component.onChange(text.text);
                            }
                        }
                        return true;
                    }
                })
            ])
        ];
        return component;
    }
}