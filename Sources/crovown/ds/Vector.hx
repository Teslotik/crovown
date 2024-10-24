package crovown.ds;

import crovown.algorithm.MathUtils;

class Vector {
    public var x = 0.0;
    public var y = 0.0;
    public var z = 0.0;
    public var w = 0.0;

    public function new(x = 0.0, y = 0.0, z = 0.0, w = 1.0) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    public static inline function X() { return new Vector(1, 0, 0, 0); }
    public static inline function Y() { return new Vector(0, 1, 0, 0); }
    public static inline function Z() { return new Vector(0, 0, 1, 0); }
    public static inline function W() { return new Vector(0, 0, 0, 1); }
    public static inline function Ones() { return new Vector(1, 1, 1, 1); }

    public inline function fromArray(v:Array<Float>) {
        x = v[0];
        y = v[1];
        z = v[2];
        w = v[3];
        return v;
    }

    public inline function toArray(v:Array<Float>) {
        v[0] = x;
        v[1] = y;
        v[2] = z;
        v[3] = w;
        return v;
    }

    public function equals(v:Vector, epsilon = 1e-6) {
        return
            Math.abs(x - v.x) < epsilon &&
            Math.abs(y - v.y) < epsilon &&
            Math.abs(z - v.z) < epsilon &&
            Math.abs(w - v.w) < epsilon;
    }

    public function toString() {
        return '{x: ${x}, y: ${y}, z: ${z}, w: ${w}}';
    }

    public inline function load(v:Vector) {
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
        this.w = v.w;
        return this;
    }

    public inline function set(x = 0.0, y = 0.0, z = 0.0, w = 1.0) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
        return this;
    }

    public inline function zeros() {
        x = 0;
        y = 0;
        z = 0;
        w = 0;
        return this;
    }

    public inline function ones() {
        x = 1;
        y = 1;
        z = 1;
        w = 1;
        return this;
    }

    public inline function clone() {
        return new Vector(x, y, z, w);
    }

    public function add(v:Vector) {
        x += v.x;
        y += v.y;
        z += v.z;
        w += v.w;
        return this;
    }

    public function addVal(x = 0.0, y = 0.0, z = 0.0, w = 0.0) {
        this.x += x;
        this.y += y;
        this.z += z;
        this.w += w;
        return this;
    }

    public function Add(v:Vector) {
        return clone().add(v);
    }

    public function sub(v:Vector) {
        x -= v.x;
        y -= v.y;
        z -= v.z;
        w -= v.w;
        return this;
    }

    public function subVal(x = 0.0, y = 0.0, z = 0.0, w = 0.0) {
        this.x -= x;
        this.y -= y;
        this.z -= z;
        this.w -= w;
        return this;
    }

    public function Sub(v:Vector) {
        return clone().sub(v);
    }

    public function multVal(v:Float) {
        x *= v;
        y *= v;
        z *= v;
        w *= v;
        return this;
    }

    public function MultVal(v:Float) {
        return clone().multVal(v);
    }

    public function multVec(v:Vector) {
        x *= v.x;
        y *= v.y;
        z *= v.z;
        w *= v.w;
        return this;
    }

    public function MultVec(v:Vector) {
        return clone().multVec(v);
    }

    public static function Dot2(x1:Float, y1:Float, x2:Float, y2:Float) {
        return x1 * x2 + y1 * y2;
    }

    public function dot3(v:Vector) {
        return x * v.x + y * v.y + z * v.z;
    }

    public function dot(v:Vector) {
        return x * v.x + y * v.y + z * v.z + w * v.w;
    }

    public function cross(v:Vector) {
        x = (y * v.z - z * v.y);
        y = (z * v.x - x * v.z);
        z = (x * v.y - y * v.x);
        return this;
    }

    public function Cross(v:Vector) {
        return clone().cross(v);
    }
    
    public function angle(v:Vector) {
        return Math.acos(dot3(v) / (length3() * v.length3()));
    }

    // @todo test
    public function isClockwise(v:Vector) {
        return angle(v) >= 0;
    }

    public function prjVec(v:Vector) {
        return multVal(dot(v) / lengthSq()) ;
    }

    public function PrjVec(v:Vector) {
        return clone().prjVec(v);
    }

    public function prjMat(v:Vector) {
        // @todo
    }

    // @todo test
    public function reflect(n:Vector) {
        var d = 2 * this.dot(n);
        x = x - d * n.x;
        y = y - d * n.y;
        z = z - d * n.z;
		return this;
    }
    
    public function Reflect(n:Vector) {
        return clone().reflect(n);
    }

    public function length3() {
        return Math.sqrt(x * x + y * y + z * z);
    }

    public function length() {
        return Math.sqrt(x * x + y * y + z * z + w * w);
    }

    public function lengthSq() {
        return x * x + y * y + z * z + w * w;
    }

    public function distance(v:Vector) {
        return Math.sqrt(
            (x - v.x) * (x - v.x) +
            (y - v.y) * (y - v.y) +
            (z - v.z) * (z - v.z) +
            (w - v.w) * (w - v.w)
        );
    }

    public function distanceSq(v:Vector) {
        return (x - v.x) * (x - v.x) +
            (y - v.y) * (y - v.y) +
            (z - v.z) * (z - v.z) +
            (w - v.w) * (w - v.w);
    }

    public function normalize() {
        var l = lengthSq();
        if (l == 0) return set(0, 0, 0, 0);
        if (l == 1) return this;
        var l = Math.sqrt(l);
        x /= l;
        y /= l;
        z /= l;
        w /= l;
        return this;
    }

    public function Normalize() {
        return clone().normalize();
    }

    public function isZero() {
        return x == 0 && y == 0 && z == 0 && w == 0;
    }

    public function isUnit(epsilon = 1e-6) {
        return Math.abs(lengthSq() - 1) < epsilon;
    }

    public function isPerpendicular(v:Vector, epsilon = 1e-6) {
        return Math.abs(dot(v)) < epsilon;
    }

    public function isSameDirection(v:Vector) {
        return dot(v) > 0;
    }

    public function isOppositeDirection(v:Vector) {
        return dot(v) < 0;
    }

    public function mix(t:Float, v:Vector) {
        x = MathUtils.mix(t, x, v.x);
        y = MathUtils.mix(t, y, v.y);
        z = MathUtils.mix(t, z, v.z);
        w = MathUtils.mix(t, w, v.w);
        return this;
    }
    
    public function Mix(t:Float, v:Vector) {
        return clone().mix(t, v);
    }

    public function clamp(?min:Float, ?max:Float) {
        x = MathUtils.clamp(x, min, max);
        y = MathUtils.clamp(y, min, max);
        z = MathUtils.clamp(z, min, max);
        w = MathUtils.clamp(w, min, max);
        return this;
    }

    public function Clamp(?min:Float, ?max:Float) {
        return clone().clamp(min, max);
    }
}