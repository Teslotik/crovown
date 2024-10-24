package crovown.algorithm;

import crovown.algorithm.MathUtils;

class SdfPainter<T> {
    public var w = 100;
    public var h = 100;

    public var cx = 0;
    public var cy = 0;
    
    public var map:Array<Null<T>> = null;

    public function new(w:Int, h:Int) {
        this.w = w;
        this.h = h;
        map = [for (i in 0...w * h) null];
    }

    public function cursor(x:Int, y:Int) {
        cx = MathUtils.clampi(x, 0, this.w);
        cy = MathUtils.clampi(y, 0, this.h);
        return this;
    }

    public function center() {
        cx = Std.int(w / 2);
        cy = Std.int(h / 2);
    }

    public function draw(f:(x:Int, y:Int, v:Null<T>)->Null<T>) {
        for (i in 0...map.length) {
            var x = Std.int(i / w);
            var y = i % w;
            var id = f(x - cx, y - cy, map[i]);
            map[i] = id ?? map[i];
            // map[i] = id;
        }
        return this;
    }
    
    public function transfer(f:(x:Int, y:Int, v:T)->Void) {
        for (i in 0...map.length) {
            var x = Std.int(i / w);
            var y = i % w;
            f(x, y, map[i]);
        }
        return this;
    }
    
    public function get(x:Int, y:Int) {
        if (x < 0 || x >= w) return null;
        if (y < 0 || y >= h) return null;
        return map[x * w + y];
    }

    public function pixel(x:Int, y:Int, v:T) {
        map[x * w + y] = v;
        return this;
    }

    public function fill(v:Null<T>) {
        for (i in 0...map.length) map[i] = v;
        return this;
    }
    
    public function replace(from:Null<T>, to:Null<T>) {
        for (i in 0...map.length) {
            if (map[i] == from) map[i] = to;
        }
    }

    public function grow(iterations = 1) {
        for (it in 0...iterations) {
            var source = map.copy();
            for (i in 0...map.length) {
                var x = Std.int(i / w);
                var y = i % w;
                if (get(x, y) != null) continue;
                var m = false;
                for (dx in -1...2) {
                    for (dy in -1...2) {
                        var v = get(x + dx, y + dy);
                        if (v != null) {
                            source[i] = v;
                            m = true;
                            break;
                        }
                    }
                    if (m) break;
                }
            }
            map = source;
        }
    }
}

class FloatPainter {
    public static function merge(painter:SdfPainter<Float>, from:SdfPainter<Float>) {
        for (i in 0...from.map.length) {
            // painter.map[i] = from.map[i] ?? painter.map[i];
            // painter.map[i] = from.map[i] > 0 ? from.map[i] : painter.map[i];
            if (from.map[i] != null) painter.map[i] = from.map[i];
        }
    }

    public static function combine(painter:SdfPainter<Float>, from:SdfPainter<Float>) {
        for (i in 0...from.map.length) {
            if (painter.map[i] != null && from.map[i] != null && painter.map[i] > 0.01 && from.map[i] > 0.01) painter.map[i] = from.map[i];
        }
    }

    public static function circle(painter:SdfPainter<Float>, radius:Int) {
        painter.draw((x, y, v) -> {
            return MathUtils.clamp(1 - Math.sqrt(x * x + y * y) / radius, 0, 1);
        });
    }

    public static function rect(painter:SdfPainter<Float>, w:Int, h:Int) {
        painter.draw((x, y, v) -> {
            return Math.min(MathUtils.clamp(1 - Math.abs(x) / w, 0, 1), MathUtils.clamp(1 - Math.abs(y) / h, 0, 1));
        });
    }

    public static function contrast(painter:SdfPainter<Float>, ?mul:Float, ?add:Float, ?pow:Float) {
        painter.draw((x, y, v) -> {
            return MathUtils.clamp(Math.pow(v * (mul ?? 1) + (add ?? 0), (pow ?? 1)), 0, 1);
        });
    }

    public static function trim(painter:SdfPainter<Float>, threshold = 0.02) {
        for (i in 0...painter.map.length) {
            painter.map[i] = painter.map[i] == null || painter.map[i] > threshold ? painter.map[i] : null;
        }
    }

    public static function outline(painter:SdfPainter<Float>, radius:Int, v:Null<Float>) {
        var source = painter.map.copy();
        for (i in 0...painter.map.length) {
            var x = Std.int(i / painter.w);
            var y = i % painter.w;
            if (painter.get(x, y) != null) continue;
            var m = false;
            for (dx in -radius...radius + 1) {
                for (dy in -radius...radius + 1) {
                    if (painter.get(x + dx, y + dy) != null) {
                        // перезаписывает себя
                        // painter.map[i] = v;
                        source[i] = v;
                        m = true;
                        break;
                    }
                }
                if (m) break;
            }
        }
        painter.map = source;
    }
    
    public static function walker(painter:SdfPainter<Float>, fromX:Int, fromY:Int, toX:Int, toY:Int, v:Null<Float>) {
        while (fromX != toX && fromY != toY) {
            if (Math.random() < 0.5) {
                var sign = toX > fromX ? 1 : -1;
                var count = sign == 1 ? MathUtils.randrange(0, toX - fromX) : MathUtils.randrange(0, fromX - toX);
                for (i in 0...count) painter.pixel(fromX + i * sign, fromY, v);
                fromX += count * sign;
            } else {
                var sign = toY > fromY ? 1 : -1;
                var count = sign == 1 ? MathUtils.randrange(0, toY - fromY) : MathUtils.randrange(0, fromY - toY);
                for (i in 0...count) painter.pixel(fromX, fromY + i * sign, v);
                fromY += count * sign;
            }
        }
    }
}