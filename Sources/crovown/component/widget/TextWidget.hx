package crovown.component.widget;

import crovown.event.PropertiesEvent;
import crovown.event.SizeEvent;
import crovown.event.DrawWidgetEvent;
import crovown.algorithm.MathUtils;
import crovown.backend.Backend.Font;
import crovown.backend.Backend.SdfShader;
import crovown.backend.Backend.Surface;

using crovown.component.widget.TextWidget;
using crovown.component.widget.property.StringProperty;
using crovown.component.widget.property.IntProperty;

@:build(crovown.Macro.component(false))
class TextWidget extends Widget {
    @:p public var text:String = "Text";
    @:p public var font:Font = null;
    @:p public var size:Float = 16;
    @:p public var contrast:Float = 0.3;
    
    // public var surfaceShader:SurfaceShader = null;
    public var shader:SdfShader = null;
    public var texture:Surface = null;

    public static function build(crow:Crovown, component:TextWidget) {
        component.horizontal = Fixed(component.font.getWidth(component.text));
        component.vertical = Fixed(component.font.getHeight(component.text));
        component.texture = crow.application.backend.loadSurface("Inter");  // @todo удалить
        return component;
    }

    @:eventHandler
    override function onDrawWidgetEvent(event:DrawWidgetEvent) {
        if (!isEnabled) return;
        // surfaceShader ??= crow.application.backend.shader(SurfaceShader.label);
        shader ??= crow.application.backend.shader(SdfShader.label);
        
        // buildTransform();

        shader.setColor(switch (color) {
            case Color(v): v;
            case null | _: BlueViolet;
        });
        shader.setThreshold(0.45);
        shader.setContrast(contrast);
        // shader.setThreshold(0.5);
        // surfaceShader.setSurface(texture);
        // stage.buffer.setShader(stage.fontShader);
        shader.setSurface(texture);
        event.buffer.setShader(shader);
        event.buffer.pushTransform(world);
        event.buffer.setFont(font);
        // event.buffer.drawString(text, -w / 2, -h / 4);
        font.setSize(size);
        event.buffer.drawString(text,
            MathUtils.mix(pivotX, -w / 2, -w),
            // MathUtils.mix(pivotY, -h / 4, -h / 2)
            MathUtils.mix(pivotY, -h / 2, -h / 2)
        );
        // trace(MathUtils.mix(pivotX, -w / 2, -w), -w / 2);
        event.buffer.flush();
        event.buffer.popTransform();
    }

    @:eventHandler
    override function onSizeEvent(event:SizeEvent) {
        // w = font.getWidth(text);
        // h = font.getHeight(text);
        // trace(w, h);
        font.setSize(size);
        horizontal = Fixed(font.getWidth(text));
        vertical = Fixed(font.getHeight(text));
    }

    @:eventHandler
    override function onPropertiesEvent(event:PropertiesEvent) {
        if (!isActive) return;
        event.group(getType());
        event.layout.addChild(crow.StringProperty(property -> {
            property.onChange = text -> this.text = text;
        }));
        event.group("Font");
        event.layout.addChild(crow.IntProperty(property -> {
            property.value = size;
            property.step = 1.0;
            property.round = 10;
            property.onChange = value -> {
                size = value;
            }
        }));
    }
    
    public static function canParent(component:Component) {
        return component.kind == crovown.types.Kind.Widget;
    }
}