package crovown.types;

import crovown.backend.Backend.Shader;
import crovown.backend.Backend.Surface;
import crovown.types.Color;
import crovown.ds.GradientPoint;

enum Fill {
    Color(v:Color);
    // @todo трёхкомпонентное начало и конец
    LinearGradient(sx:Float, sy:Float, ex:Float, ey:Float, points:Array<GradientPoint>);
    Image(w:Float, h:Float, image:Surface, ?cover:Cover);
    // @todo remove
    Tile(x:Float, y:Float, w:Float, h:Float, image:Surface, ?color:Int);
    Shader(s:Shader);
}