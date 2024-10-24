package crovown.algorithm;

import crovown.ds.Vector;

// @todo проверить авторство функций
class MathUtils {
    public static function clamp(v:Null<Float>, min:Null<Float>, max:Null<Float>) {
        if (v == null) return null;
        v = Math.max(v, min ?? v);
        v = Math.min(v, max ?? v);
        return v;
    }

    public static function clampi(v:Null<Int>, min:Null<Int>, max:Null<Int>) {
        if (v == null) return null;
        min ??= v;
        max ??= v;
        v = v > min ? v : min;
        v = v < max ? v : max;
        return v;
    }

    // @todo test and use
    public static function clampg<T:Int & Float>(v:Null<T>, min:Null<T>, max:Null<T>) {
        if (v == null) return null;
        min ??= v;
        max ??= v;
        v = v > min ? v : min;
        v = v < max ? v : max;
        return v;
    }

    public static function lerp(t:Float, x0:Float, y0:Float, x1:Float, y1:Float) {
        return y0 + (t - x0) * (y1 - y0) / (x1 - x0);
    }

    public static function mix(t:Float, x:Float, y:Float) {
        return x + t * (y - x);
    }

    public static function mod(x:Float, y:Float) {
        return Math.floor(x / y) * y;
    }

    public static function fmod(x:Float, y:Float) {
        return x - Std.int(x / y) * y;
    }

    public static inline function fract(v:Float) {
        return v - Math.floor(v);
    }

    // https://docs.gl/sl4/smoothstep
    public static function smoothstep(v:Float, a:Float, b:Float) {
        var t = clamp((v - a) / (b - a), 0.0, 1.0);
        return t * t * (3.0 - 2.0 * t);
    }

    public static function randrange(min:Int, max:Int, step = 1) {
        return min + Std.int(Math.random() * ((max - min) + 1) / step) * step;
    }

    public static function choice<T>(v:Array<T>) {
        if (v.length == 0) return null;
        return v[Std.int(Math.random() * v.length)];
    }

    public static inline function radians(degrees:Float) {
        return degrees * Math.PI / 180.0;
    }

    public static inline function degrees(radians:Float) {
        return radians * 180.0 / Math.PI;
    }

    // Xorshift*32
    // Based on George Marsaglia's work: http://www.jstatsoft.org/v08/i14/paper
    public static function hashInt(v:Int):Int {
        v ^= v << 13;
        v ^= v >> 17;
        v ^= v << 5;
        return v;
    }

    // https://www.shadertoy.com/view/lsf3WH
    public static function hashHugoElias(v:Int) {
        v = (v << 13) ^ v;
        return v * (v * v * 15731 + 789221) + 1376312589;
    }

    public static function hash2D(x:Int, y:Int) {
        // Combine lower halves of coordinates
        x = (x << 16) | (y & 0xffff);

        final seed = 0x332ff52d;

        // Based on algorithm by Thomas Mueller
        x ^= x >> 16;
        x *= seed;
        x ^= x >> 16;
        x *= seed;
        x ^= x >> 16;
        return x;
    }
    
    // https://www.shadertoy.com/view/stjGRR
    // MurmurHash
    public static function hash2d(x:Int, y:Int, seed = 0x578437ad) {
        var m = 0x5bd1e995;
        var hash = seed;
        
        // process first vector element
        var k = x; 
        k *= m;
        k ^= k >> 24;
        k *= m;
        hash *= m;
        hash ^= k;
        
        // process second vector element
        k = y; 
        k *= m;
        k ^= k >> 24;
        k *= m;
        hash *= m;
        hash ^= k;

        // some final mixing
        hash ^= hash >> 13;
        hash *= m;
        hash ^= hash >> 15;
        return hash;

        // float value = float(hashValue) / float(0xffffffffU);
    }

    // https://stackoverflow.com/questions/664014/what-integer-hash-function-are-good-that-accepts-an-integer-hash-key
    // @todo Thomas Mueller?
    // public static function hashInt(v:Int):Int {
    //     v = ((v >> 16) ^ v) * 0x45d9f3b;
    //     v = ((v >> 16) ^ v) * 0x45d9f3b;
    //     v = (v >> 16) ^ v;
    //     return v;
    // }

    // https://cp-algorithms.com/string/string-hashing.html
    public static function hashString(string:String) {
        final p = 31;
        final m = 1000000009;
        var hash = 0;
        var pow = 1;
        var start = "A".code + 1;
        for (i in 0...string.length) {
            hash = (hash + (string.charCodeAt(i) - start) * pow) % m;
            pow = (pow * p) % m;
        }
        return hash;
    }

    // public static function random(v) {
        
    // }

    public static function random(x:Int) {
        x = (x << 13) ^ x;
        // return (1.0 - ((x * (x * x * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0);
        return ((x * (x * x * 15731 + 789221) + 1376312589) & 0x7fffffff) / (1073741824.0 * 2);
    }

    public static function random2D(x:Int, y:Int) {
        return ((x * 1836311903) ^ Std.int(y * 2971215073) + Std.int(4807526976));
    }

    public static inline function Ccw(a:Vector, b:Vector, c:Vector) {
        return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
    }

    public static inline function isIntersects(a:Vector, b:Vector, c:Vector, d:Vector) {
        return Ccw(a, b, c) * Ccw(a, b, d) < 0 && Ccw(c, d, b) * Ccw(c, d, a) < 0;
    }

    // https://blog.finxter.com/5-best-ways-to-check-whether-the-point-x-y-lies-on-a-given-line-in-python/
    public static function isOnLine(x:Float, y:Float, x1:Float, y1:Float, x2:Float, y2:Float, epsilon = 1e-6) {
        return Math.abs((y2 - y1) * (x - x1) - (y - y1) * (x2 - x1)) < epsilon;
    }
    
    // https://stackoverflow.com/questions/11907947/how-to-check-if-a-point-lies-on-a-line-between-2-other-points
    public static function isOnSegment(x:Float, y:Float, x1:Float, y1:Float, x2:Float, y2:Float, epsilon = 1e-6) {
        var v1x = x2 - x1;
        var v1y = y2 - y1;
        var l = Math.sqrt(v1x * v1x + v1y * v1y);
        v1x /= l;
        v1y /= l;

        var v2x = x - x1;
        var v2y = y - y1;
        var l = Math.sqrt(v2x * v2x + v2y * v2y);
        v2x /= l;
        v2y /= l;

        var v3x = x - x2;
        var v3y = y - y2;
        
        return Math.abs(Vector.Dot2(v2x, v2y, v1x, v1y) - 1.0) < epsilon && Vector.Dot2(v3x, v3y, v1x, v1y) < 0.0;
    }
}