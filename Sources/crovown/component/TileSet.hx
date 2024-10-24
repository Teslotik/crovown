package crovown.component;

import crovown.backend.Backend.Surface;

@:build(crovown.Macro.component())
class TileSet extends Component {
    @:p public var surface:Surface = null;
    @:p public var width = 100;
    @:p public var height = 100;
    @:p public var size = 16;

    public static function build(crow:Crovown, component:TileSet) {
        return component;
    }
}