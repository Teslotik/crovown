package crovown.ds;

class Rectangle {
    public var x = 0.0;
    public var y = 0.0;
    public var w = 0.0;
    public var h = 0.0;

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

    public var middle(get, set):Vector;
    function get_middle() { return new Vector(x + w / 2, y + h / 2); }
    function set_middle(v:Vector) {
        x = v.x - w / 2;
        y = v.y - h / 2;
        return v;
    }

    public function new(x = 0.0, y = 0.0, w = 0.0, h = 0.0) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    public static function Corners(left:Float, top:Float, right:Float, bottom:Float) {
        return new Rectangle().setCorners(left, top, right, bottom);
    }

    public static function Center(x:Float, y:Float, xr:Float, yr:Float) {
        return new Rectangle(x - xr, y - yr, x + xr, y + yr);
    }

    public function serialize() {
        return {
            x: x,
            y:y,
            w: w,
            h: h
        }
    }

    public function deserialize(v) {
        x = v.x;
        y = v.y;
        w = v.w;
        h = v.h;
        return this;
    }

    public inline function set(x = 0.0, y = 0.0, w = 0.0, h = 0.0) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        return this;
    }

    public inline function setCorners(left:Float, top:Float, right:Float, bottom:Float) {
        return set(left, top, right - left, bottom - top);
    }

    public inline function load(v:Rectangle) {
        return set(v.x, v.y, v.w, v.h);
    }

    public inline function clone() {
        return new Rectangle(x, y, w, h);
    }

    public function toString() {
        return '{${x}, ${y}, ${w}, ${h}}';
    }

    public function isInside(x:Float, y:Float) {
        return
            x >= this.x && x <= this.x + w &&
            y >= this.y && y <= this.y + h;
    }

    public function isIntersects(x:Float, y:Float, w:Float, h:Float) {
        return
            x + w > this.x && x < this.x + this.w &&
            y + h > this.y && y < this.y + this.h;
    }

    public inline function add(v:Rectangle) {
        return set(x + v.x, y + v.y, w + v.w, h + v.h);
    }

    public inline function Add(v:Rectangle) {
        return new Rectangle(x + v.x, y + v.y, w + v.w, h + v.h);
    }

    public inline function union(v:Rectangle) {
        var x = Math.min(x, v.x);
        var y = Math.min(y, v.y);
        var w = this.x + w > v.x + v.w ? -x + w + this.x: -x + v.w + v.x;
        var h = this.y + h > v.y + v.h ? -y + h + this.y: -y + v.h + v.y;
        // trace(this, v, new Rectangle(x, y, w, h), this.x, this.w, v.x, v.w, x, w);
        return set(x, y, w, h);
    }

    public inline function Union(v:Rectangle) {
        return clone().union(v);
    }

    public inline function extend(x:Float, y:Float) {
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
    }

    public inline function grow(dx:Float, dy:Float, w:Float, h:Float) {
        x = x - w + dx;
        this.w += w * 2;
        y = y - h + dy;
        this.h += h * 2;
    }
}