package crovown.algorithm;

import crovown.ds.Vector;

class Noise {
    // @todo change
    // https://www.shadertoy.com/view/lsf3WH
    static function hash2D(x:Float, y:Float) {
        var px = 50.0 * MathUtils.fract(x * 0.3183099 + 0.71);
        var py = 50.0 * MathUtils.fract(y * 0.3183099 + 0.113);
        return -1.0 + 2.0 * MathUtils.fract(px * py * (px + py));
    }

    // https://www.shadertoy.com/view/lsf3WH
    public static function value(x:Float, y:Float) {
        var ix = Math.floor(x);
        var iy = Math.floor(y);
        var fx = MathUtils.fract(x);
        var fy = MathUtils.fract(y);

        // @todo inlinde function fade()

        var ux = fx * fx * fx * (fx * (fx * 6.0 - 15.0) + 10.0);
        var uy = fy * fy * fy * (fy * (fy * 6.0 - 15.0) + 10.0);

        var tx = MathUtils.mix(ux, hash2D(ix, iy), hash2D(ix + 1, iy));
        var bx = MathUtils.mix(ux, hash2D(ix, iy + 1), hash2D(ix + 1, iy + 1));
        return MathUtils.mix(uy, tx, bx);
    }

    public static function valueOctave(x:Float, y:Float, scale = 1.0, octaves = 4, persistent = 1.0, lacunarity = 1.0) {
        var noise = 0.0;
        var amplitude = 0.5;
        var frequency = 1.0;
        for (octave in 0...octaves) {
            noise += value(x / scale * frequency, y / scale * frequency) * amplitude;
            amplitude *= persistent;
            frequency *= lacunarity;
        }
        return noise / 2 + 0.5;

        // var noise = 0.0;
        // var amplitude = 1.0;
        // var frequency = 1.0;
        // var height = 0.0;
        // for (octave in 0...octaves) {
        //     noise += value(x / scale * frequency, y / scale * frequency) * amplitude;
        //     height += amplitude;
        //     amplitude *= persistent;
        //     frequency *= lacunarity;
        // }
        // return noise / height / 2 + 0.5;
    }
    

    // @todo не работает пока что
    public static function perlin2D(x:Float, y:Float) {
        var left = Std.int(x);
        var top = Std.int(y);

        // локальные координаты точки внутри квадрата
        var dx = x - left;
        var dy = y - top;

        // извлекаем градиентные векторы для всех вершин квадрата:
        var gradTLx = MathUtils.hashInt(left);
        var gradTLy = MathUtils.hashInt(top);
        var gradTRx = MathUtils.hashInt(left + 1);
        var gradTRy = MathUtils.hashInt(top);
        var gradBLx = MathUtils.hashInt(left);
        var gradBLy = MathUtils.hashInt(top + 1);
        var gradBRx = MathUtils.hashInt(left + 1);
        var gradBRy = MathUtils.hashInt(top + 1);


        var tx1 = Vector.Dot2(dx, dy, gradTLx, gradTLy);
        var tx2 = Vector.Dot2(dx - 1, dy, gradTRx, gradTRy);
        var bx1 = Vector.Dot2(dx, dy - 1, gradBLx, gradBLy);
        var bx2 = Vector.Dot2(dx - 1, dy - 1, gradBRx, gradBRy);
        trace(tx1, tx2, bx1, bx2);
        
        // готовим параметры интерполяции, чтобы она не была линейной:
        var dx = Easing.easeInOutQuint(dx);
        var dy = Easing.easeInOutQuint(dy);

        // собственно, интерполяция:
        var tx = MathUtils.mix(dx, tx1, tx2);
        var bx = MathUtils.mix(dx, bx1, bx2);
        var tb = MathUtils.mix(dy, tx, bx);

        return tb;
    }
}