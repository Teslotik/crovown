package crovown.ds;

class Box {
    public var x = 0.0;
    public var y = 0.0;
    public var z = 0.0;
    public var w = 0.0;
    public var h = 0.0;
    public var d = 0.0;

    public var left(get, set):Float;
    inline function get_left() { return x; }
    inline function set_left(v:Float) { return x = v; }

    public var right(get, set):Float;
    inline function get_right() { return x + w; }
    inline function set_right(v:Float) { return w = v - x; }

    public var top(get, set):Float;
    inline function get_top() { return y; }
    inline function set_top(v:Float) { return y = v; }

    public var bottom(get, set):Float;
    inline function get_bottom() { return y + h; }
    inline function set_bottom(v:Float) { return h = v - y; }

    public var front(get, set):Float;
    inline function get_front() { return z; }
    inline function set_front(v:Float) { return z = v; }

    public var back(get, set):Float;
    inline function get_back() { return z + d; }
    inline function set_back(v:Float) { return d = v - z; }

    public var middle(get, set):Vector;
    function get_middle() { return new Vector(x + w / 2, y + h / 2, z + d / 2); }
    function set_middle(v:Vector) {
        x = v.x - w / 2;
        y = v.y - h / 2;
        z = v.z - d / 2;
        return v;
    }

    public function new(x = 0.0, y = 0.0, z = 0.0, w = 0.0, h = 0.0, d = 0.0) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
        this.h = h;
        this.d = d;
    }

    public static function Corners(left:Float, top:Float, front:Float, right:Float, bottom:Float, back:Float) {
        return new Box(left, right, front, right - left, bottom - top, back - front);
    }

    public static function Center(x:Float, y:Float, z:Float, xr:Float, yr:Float, zr:Float) {
        return new Box(x - xr, y - yr, z - zr, x + xr, y + yr, z + zr);
    }

    public inline function set(x = 0.0, y = 0.0, z = 0.0, w = 0.0, h = 0.0, d = 0.0) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
        this.h = h;
        this.d = d;
        return this;
    }

    public function toString() {
        return '{${x}, ${y}, ${z}, ${w}, ${h}, ${d}}';
    }
    
    public function isInside(x:Float, y:Float, z:Float) {
        return
            x >= this.x && x <= this.x + w &&
            y >= this.y && y <= this.y + h &&
            z >= this.z && z <= this.z + d;
    }

    public function isIntersects(x:Float, y:Float, z:Float, w:Float, h:Float, d:Float) {
        return
            x + w > this.x && x < this.x + this.w &&
            y + h > this.y && y < this.y + this.h &&
            z + d > this.z && z < this.z + this.d;
    }

    public inline function extend(x:Float, y:Float, z:Float) {
        if (x < left) {
            w += this.x - x;
            this.x = x;
        } else if (x > right) {
            right = x;
        }

        if (y < top) {
            h += this.y - y;
            this.y = y;
        } else if (y > bottom) {
            bottom = y;
        }

        if (z < front) {
            d += this.z - z;
            this.z = z;
        } else if (z > back) {
            back = z;
        }
    }
}