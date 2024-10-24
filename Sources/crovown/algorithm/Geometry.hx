package crovown.algorithm;

import crovown.ds.Vector;
import crovown.types.Anchor;

class Geometry {
    @:noUsing public static function anchor(?left:Anchor, ?right:Anchor, size:Float, w:Float, ?setLeft:Float->Void = null, ?setRight:Float->Void = null) {
        if (left == null && right == null) {
            if (setLeft != null) setLeft(0);
            if (setRight != null) setRight(size);
            return;
        }
        
        // Calculating offsets relative to the borders
        // left
        var dl = switch (left) {
            case null: 0;
            case Fixed(v): v;
            case Scale(v): size - size * v;
            case Center(v): size / 2 - v;
        }
        // right
        var dr = switch (right) {
            case null: 0;
            case Fixed(v): v;
            case Scale(v): size - size * v;
            case Center(v): size / 2 - v;
        }

        // Converting offsets to absolute values
        var l = 0.0;
        var r = 0.0;
        if (left != null && right != null) {
            l = dl;
            r = size - dl - dr;
        } else if (left != null) {
            l = dl;
            r = w;
        } else if (right != null) {
            r = w;
            l = size - r - dr;
        }

        if (setLeft != null) setLeft(l);
        if (setRight != null) setRight(r);
    }

    public static function space(spacing:Float, count:Int) {
        return Math.max(count - 1, 0) * spacing;
    }

    public static function distribute(space:Float, count:Int) {
        if (count <= 0) return space;
        return space / (count - 1);
    }

    @:noUsing public static function locate(f:Float, pos:Float, size:Float, content:Float) {
        return MathUtils.lerp(f, -1, pos, 1, pos + size - content);
    }
}