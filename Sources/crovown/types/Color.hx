package crovown.types;

import crovown.ds.Vector;
import crovown.algorithm.MathUtils;

// HTML colors
enum abstract Color(Int) from Int to Int {
    var Transparent = 0x0;
    var TransparentWhite = 0x00FFFFFF;  // @todo rename

    // Pink colors
    var MediumVioletRed = 0xFFC71585;
    var DeepPink = 0xFFFF1493;
    var PaleVioletRed = 0xFFDB7093;
    var HotPink = 0xFFFF69B4;
    var LightPink = 0xFFFFB6C1;
    var Pink = 0xFFFFC0CB;

    // Red colors
    var DarkRed = 0xFF8B0000;
    var Red = 0xFFFF0000;
    var Firebrick = 0xFFB22222;
    var Crimson = 0xFFDC143C;
    var IndianRed = 0xFFCD5C5C;
    var LightCoral = 0xFFF08080;
    var Salmon = 0xFFFA8072;
    var DarkSalmon = 0xFFE9967A;
    var LightSalmon = 0xFFFFA07A;

    // Orange colors
    var OrangeRed = 0xFFFF4500;
    var Tomato = 0xFFFF6347;
    var DarkOrange = 0xFFFF8C00;
    var Coral = 0xFFFF7F50;
    var Orange = 0xFFFFA500;

    // Yellow colors
    var DarkKhaki = 0xFFBDB76B;
    var Gold = 0xFFFFD700;
    var Khaki = 0xFFF0E68C;
    var PeachPuff = 0xFFFFDAB9;
    var Yellow = 0xFFFFFF00;
    var PaleGoldenrod = 0xFFEEE8AA;
    var Moccasin = 0xFFFFE4B5;
    var PapayaWhip = 0xFFFFEFD5;
    var LightGoldenrodYellow = 0xFFFAFAD2;
    var LemonChiffon = 0xFFFFFACD;
    var LightYellow = 0xFFFFFFE0;

    // Brown colors
    var Maroon = 0xFF800000;
    var Brown = 0xFFA52A2A;
    var SaddleBrown = 0xFF8B4513;
    var Sienna = 0xFFA0522D;
    var Chocolate = 0xFFD2691E;
    var DarkGoldenrod = 0xFFB8860B;
    var Peru = 0xFFCD853F;
    var RosyBrown = 0xFFBC8F8F;
    var Goldenrod = 0xFFDAA520;
    var SandyBrown = 0xFFF4A460;
    var Tan = 0xFFD2B48C;
    var Burlywood = 0xFFDEB887;
    var Wheat = 0xFFF5DEB3;
    var NavajoWhite = 0xFFFFDEAD;
    var Bisque = 0xFFFFE4C4;
    var BlanchedAlmond = 0xFFFFEBCD;
    var Cornsilk = 0xFFFFF8DC;

    // Purple, violet, and magenta colors
    var Indigo = 0xFF4B0082;
    var Purple = 0xFF800080;
    var DarkMagenta = 0xFF8B008B;
    var DarkViolet = 0xFF9400D3;
    var DarkSlateBlue = 0xFF483D8B;
    var BlueViolet = 0xFF8A2BE2;
    var DarkOrchid = 0xFF9932CC;
    var Fuchsia = 0xFFFF00FF;
    var Magenta = 0xFFFF00FF;
    var SlateBlue = 0xFF6A5ACD;
    var MediumSlateBlue = 0xFF7B68EE;
    var MediumOrchid = 0xFFBA55D3;
    var MediumPurple = 0xFF9370DB;
    var Orchid = 0xFFDA70D6;
    var Violet = 0xFFEE82EE;
    var Plum = 0xFFDDA0DD;
    var Thistle = 0xFFD8BFD8;
    var Lavender = 0xFFE6E6FA;

    // Blue colors
    var MidnightBlue = 0xFF191970;
    var Navy = 0xFF000080;
    var DarkBlue = 0xFF00008B;
    var MediumBlue = 0xFF0000CD;
    var Blue = 0xFF0000FF;
    var RoyalBlue = 0xFF4169E1;
    var SteelBlue = 0xFF4682B4;
    var DodgerBlue = 0xFF1E90FF;
    var DeepSkyBlue = 0xFF00BFFF;
    var CornflowerBlue = 0xFF6495ED;
    var SkyBlue = 0xFF87CEEB;
    var LightSkyBlue = 0xFF87CEFA;
    var LightSteelBlue = 0xFFB0C4DE;
    var LightBlue = 0xFFADD8E6;
    var PowderBlue = 0xFFB0E0E6;

    // Cyan colors
    var Teal = 0xFF008080;
    var DarkCyan = 0xFF008B8B;
    var LightSeaGreen = 0xFF20B2AA;
    var CadetBlue = 0xFF5F9EA0;
    var DarkTurquoise = 0xFF00CED1;
    var MediumTurquoise = 0xFF48D1CC;
    var Turquoise = 0xFF40E0D0;
    var Aqua = 0xFF00FFFF;
    var Cyan = 0xFF00FFFF;
    var Aquamarine = 0xFF7FFFD4;
    var PaleTurquoise = 0xFFAFEEEE;
    var LightCyan = 0xFFE0FFFF;

    // Green colors
    var DarkGreen = 0xFF006400;
    var Green = 0xFF008000;
    var DarkOliveGreen = 0xFF556B2F;
    var ForestGreen = 0xFF228B22;
    var SeaGreen = 0xFF2E8B57;
    var Olive = 0xFF808000;
    var OliveDrab = 0xFF6B8E23;
    var MediumSeaGreen = 0xFF3CB371;
    var LimeGreen = 0xFF32CD32;
    var Lime = 0xFF00FF00;
    var SpringGreen = 0xFF00FF7F;
    var MediumSpringGreen = 0xFF00FA9A;
    var DarkSeaGreen = 0xFF8FBC8F;
    var MediumAquamarine = 0xFF66CDAA;
    var YellowGreen = 0xFF9ACD32;
    var LawnGreen = 0xFF7CFC00;
    var Chartreuse = 0xFF7FFF00;
    var LightGreen = 0xFF90EE90;
    var GreenYellow = 0xFFADFF2F;
    var PaleGreen = 0xFF98FB98;

    // White colors
    var MistyRose = 0xFFFFE4E1;
    var AntiqueWhite = 0xFFFAEBD7;
    var Linen = 0xFFFAF0E6;
    var Beige = 0xFFF5F5DC;
    var WhiteSmoke = 0xFFF5F5F5;
    var LavenderBlush = 0xFFFFF0F5;
    var OldLace = 0xFFFDF5E6;
    var AliceBlue = 0xFFF0F8FF;
    var Seashell = 0xFFFFF5EE;
    var GhostWhite = 0xFFF8F8FF;
    var Honeydew = 0xFFF0FFF0;
    var FloralWhite = 0xFFFFFAF0;
    var Azure = 0xFFF0FFFF;
    var MintCream = 0xFFF5FFFA;
    var Snow = 0xFFFFFAFA;
    var Ivory = 0xFFFFFFF0;
    var White = 0xFFFFFFFF;

    // Gray and black colors
    var Black = 0xFF000000;
    var DarkSlateGray = 0xFF2F4F4F;
    var DimGray = 0xFF696969;
    var SlateGray = 0xFF708090;
    var Gray = 0xFF808080;
    var LightSlateGray = 0xFF778899;
    var DarkGray = 0xFFA9A9A9;
    var Silver = 0xFFC0C0C0;
    var LightGray = 0xFFD3D3D3;
    var Gainsboro = 0xFFDCDCDC;

    public static inline function toARGB(r:Float, g:Float, b:Float, a:Float):Int {
        return (Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255);
    }

    public static inline function toRGBA(r:Float, g:Float, b:Float, a:Float):Int {
        return (Std.int(r * 255) << 24) | (Std.int(g * 255) << 16) | (Std.int(b * 255) << 8) | Std.int(a * 255);
    }

    public static inline function toBGRA(r:Float, g:Float, b:Float, a:Float):Int {
        return (Std.int(b * 255) << 24) | (Std.int(g * 255) << 16) | (Std.int(r * 255) << 8) | Std.int(a * 255);
    }

    public static inline function toABGR(r:Float, g:Float, b:Float, a:Float):Int {
        return (Std.int(a * 255) << 24) | (Std.int(b * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(r * 255);
    }

    public static inline function randARGB():Int {
        return toARGB(1, Math.random(), Math.random(), Math.random());
    }

    public static inline function fromARGB(color:Color) {
        return new Vector(
            (color >> 16 & 0xFF) / 255.0,
            (color >> 8  & 0xFF) / 255.0,
            (color       & 0xFF) / 255.0,
            (color >> 24 & 0xFF) / 255.0
        );
    }

    public static inline function fromHSVA(h:Float, s:Float, v:Float, a:Float) {
        var H = h * 360;
        var C = s * v;
        var X = C * (1 - Math.abs(MathUtils.fmod(H / 60.0, 2) - 1));
        var m = v - C;
        var r = 0.0;
        var g = 0.0;
        var b = 0.0;
        if(H >= 0 && H < 60) {
            r = C; g = X; b = 0;
        } else if (H >= 60 && H < 120) {
            r = X; g = C; b = 0;
        } else if (H >= 120 && H < 180) {
            r = 0; g = C; b = X;
        } else if (H >= 180 && H < 240) {
            r = 0; g = X; b = C;
        } else if (H >= 240 && H < 300) {
            r = X; g = 0; b = C;
        } else {
            r = C; g = 0; b = X;
        }
        return toARGB(r + m, g + m, b + m, a);
    }

    public static function toHSVA(r:Float, g:Float, b:Float, a:Float) {
        var max = Math.max(Math.max(r, g), b);
        var min = Math.min(Math.min(r, g), b);
        var delta = max - min;
        var h = 0.0;
        var s = 0.0;
        var v = 0.0;
        if (delta > 0) {
            if (max == r) {
                h = 60 * (MathUtils.fmod(((g - b) / delta), 6));
            } else if (max == g) {
                h = 60 * (((b - r) / delta) + 2);
            } else if (max == b) {
                h = 60 * (((r - g) / delta) + 4);
            }
            
            if (max > 0) {
                s = delta / max;
            } else {
                s = 0;
            }
            
            v = max;
        } else {
            h = 0;
            s = 0;
            v = max;
        }
        
        if (h < 0) {
            h = 360 + h;
        }
        return new Vector(h / 360, s, v, a);
    }

    public static function ARGBToHSVA(color:Color) {
        var r = (color >> 16 & 0xFF) / 255.0;
        var g = (color >> 8  & 0xFF) / 255.0;
        var b = (color       & 0xFF) / 255.0;
        var a = (color >> 24 & 0xFF) / 255.0;
        return toHSVA(r, g, b, a);
    }
}