package crovown.component.filter;

import crovown.interfaces.Renderable;
import crovown.backend.Backend.OutlineShader;
import crovown.backend.Backend.Shader;
import crovown.backend.Backend.Surface;
import crovown.ds.Rectangle;
import crovown.types.Kind;

@:build(crovown.Macro.component(false))
class Filter extends Component {
    public var zone = new Rectangle();

    public function new() {
        super();
        kind = Kind.Filter;
    }

    public static function build(crow:Crovown, component:Filter) {
        return component;
    }

    public function onForward(canvas:Renderable, bounds:Rectangle) {
        
    }

    public function onBackward(canvas:Renderable, bounds:Rectangle) {
        
    }
}