package crovown.component.filter;

import crovown.backend.Backend.AdjustColorShader;
import crovown.backend.Backend.Surface;
import crovown.ds.Rectangle;

@:build(crovown.Macro.component(false))
class AdjustColorFilter extends Filter {
    public static function build(crow:Crovown, component:AdjustColorFilter) {
        // component.shader = crow.application.backend.shader(AdjustColorShader.label);
        return component;
    }
}