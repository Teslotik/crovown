package crovown.algorithm;

import crovown.backend.Backend.Surface;

class Shape {
    static inline final resolution = 32;

    public static function drawLine(surface:Surface, x1:Float, y1:Float, x2:Float, y2:Float, width:Float) {
        var dirX = x2 - x1;
        var dirY = y2 - y1;

        var mag = Math.sqrt(dirX * dirX + dirY * dirY);
        var pX = (-dirY / mag) * width / 2;
        var pY = (dirX / mag) * width / 2;

        surface.drawTri(x1 - pX, y1 - pY, x1 + pX, y1 + pY, x2 + pX, y2 + pY);
        surface.drawTri(x2 + pX, y2 + pY, x1 - pX, y1 - pY, x2 - pX, y2 - pY);
    }
    
    public static function drawRect(surface:Surface, x:Float, y:Float, w:Float, h:Float) {
        surface.drawTri(x, y, x, y + h, x + w, y + h);  // bottom left
        surface.drawTri(x, y, x + w, y + h, x + w, y);  // top right
    }

    // @todo зацикливание - [0, 361]
    @:noUsing public static function arc(start:Int, end:Int, w = 1.0, h = 1.0, resolution = 16) {
        var values = [];
        
        var start = MathUtils.radians(start);
        var end = MathUtils.radians(end);
        var resolution = resolution < 3 ? 3 : resolution;
        
        var step = (end - start) / (resolution - 1);
        var offset = 0.0;
        for (_ in 0...resolution) {
            values.push(Math.cos(start + offset) * w);
            values.push(Math.sin(start + offset) * h);
            offset += step;
        }

        return values;
    }

    // static public function drawArc(surface:Surface) {
        
    // }

    public static function drawCircle(surface:Surface, x:Float, y:Float, w:Float, h:Float) {
        static final circle = Shape.arc(0, 360, 1, 1, resolution);
        static var points:Array<Float> = null;
        points ??= [for (_ in 0...resolution * 3) 0.0];
        
        for (i in 0...resolution) {
            points[i * 3 + 0] = x + circle[i * 2 + 0] * w;
            points[i * 3 + 1] = y + circle[i * 2 + 1] * h;
        }

        surface.drawConvexPolygon(points);
    }

    // @todo
    public static function drawArc(x:Float, y:Float, w:Float, h:Float, start = 0.0, end = 360.0) {

    }

    public static function drawRoundedRect(surface:Surface, x:Float, y:Float, w:Float, h:Float, r1:Float, r2:Float, r3:Float, r4:Float) {
        // @todo increase resolution
        static final topLeft = Shape.arc(180, 270, 1, 1, Std.int(resolution / 4));
        static final topRight = Shape.arc(270, 360, 1, 1, Std.int(resolution / 4));
        static final bottomRight = Shape.arc(0, 90, 1, 1, Std.int(resolution / 4));
        static final bottomLeft = Shape.arc(90, 180, 1, 1, Std.int(resolution / 4));
        static var points:Array<Float> = null;
        points ??= [for (_ in 0...resolution * 3) 0.0];

        // @todo change algorithm
        if (r1 + r2 > h) {
            var t = h / (r1 + r2);
            r1 *= t;
            r2 *= t;
        }
        if (r2 + r3 > w) {
            var t = w / (r2 + r3);
            r2 *= t;
            r3 *= t;
        }
        if (r3 + r4 > h) {
            var t = h / (r3 + r4);
            r3 *= t;
            r4 *= t;
        }
        if (r4 + r1 > w) {
            var t = w / (r4 + r1);
            r4 *= t;
            r1 *= t;
        }

        var count = Std.int(resolution / 4);
        for (i in 0...count) {
            points[(i + 0) * 3 + 0] = x + topLeft[i * 2 + 0] * r1 + r1;
            points[(i + 0) * 3 + 1] = y + topLeft[i * 2 + 1] * r1 + r1;
        }
        for (i in 0...count) {
            points[(i + count) * 3 + 0] = x + w + topRight[i * 2 + 0] * r2 - r2;
            points[(i + count) * 3 + 1] = y + topRight[i * 2 + 1] * r2 + r2;
        }
        for (i in 0...count) {
            points[(i + count * 2) * 3 + 0] = x + w + bottomRight[i * 2 + 0] * r3 - r3;
            points[(i + count * 2) * 3 + 1] = y + h + bottomRight[i * 2 + 1] * r3 - r3;
        }
        for (i in 0...count) {
            points[(i + count * 3) * 3 + 0] = x + bottomLeft[i * 2 + 0] * r4 + r4;
            points[(i + count * 3) * 3 + 1] = y + h + bottomLeft[i * 2 + 1] * r4 - r4;
        }
        
        surface.drawConvexPolygon(points);
    }
}