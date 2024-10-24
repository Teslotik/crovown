package crovown.algorithm;

// https://easings.net
class Easing {
    public static function easeInOutLinear(x:Float):Float {
        return x;
    }
    
    public static function easeInSine(x:Float):Float {
        return 1 - Math.cos((x * Math.PI) / 2);
    }

    public static function easeOutSine(x:Float):Float {
        return Math.sin((x * Math.PI) / 2);
    }

    public static function easeInOutSine(x:Float):Float {
        return -(Math.cos(Math.PI * x) - 1) / 2;
    }

    public static function easeInQuad(x:Float):Float {
        return x * x;
    }

    public static function easeOutQuad(x:Float):Float {
        return 1 - (1 - x) * (1 - x);
    }

    public static function easeInOutQuad(x:Float):Float {
        return x < 0.5 ? 2 * x * x : 1 - Math.pow(-2 * x + 2, 2) / 2;
    }


    public static function easeInCubic(x:Float):Float {
        return x * x * x;
    }

    public static function easeOutCubic(x:Float):Float {
        return 1 - Math.pow(1 - x, 3);
    }

    public static function easeInOutCubic(x:Float):Float {
        return x < 0.5 ? 4 * x * x * x : 1 - Math.pow(-2 * x + 2, 3) / 2;
    }

    public static function easeInQuart(x:Float):Float {
        return x * x * x * x;
    }

    public static function easeOutQuart(x:Float):Float {
        return 1 - Math.pow(1 - x, 4);
    }

    public static function easeInOutQuart(x:Float):Float {
        return x < 0.5 ? 8 * x * x * x * x : 1 - Math.pow(-2 * x + 2, 4) / 2;
    }


    public static function easeInQuint(x:Float):Float {
        return x * x * x * x * x;
    }

    public static function easeOutQuint(x:Float):Float {
        return 1 - Math.pow(1 - x, 5);
    }

    public static function easeInOutQuint(x:Float):Float {
        return x < 0.5 ? 16 * x * x * x * x * x : 1 - Math.pow(-2 * x + 2, 5) / 2;
    }

    public static function easeInExpo(x:Float):Float {
        return x == 0 ? 0 : Math.pow(2, 10 * x - 10);
    }

    public static function easeOutExpo(x:Float):Float {
        return x == 1 ? 1 : 1 - Math.pow(2, -10 * x);
    }

    public static function easeInOutExpo(x:Float):Float {
        return x == 0
            ? 0
            : x == 1
            ? 1
            : x < 0.5 ? Math.pow(2, 20 * x - 10) / 2
            : (2 - Math.pow(2, -20 * x + 10)) / 2;
    }


    public static function easeInCirc(x:Float):Float {
        return 1 - Math.sqrt(1 - Math.pow(x, 2));
    }

    public static function easeOutCirc(x:Float):Float {
        return Math.sqrt(1 - Math.pow(x - 1, 2));
    }

    public static function easeInOutCirc(x:Float):Float {
        return x < 0.5
            ? (1 - Math.sqrt(1 - Math.pow(2 * x, 2))) / 2
            : (Math.sqrt(1 - Math.pow(-2 * x + 2, 2)) + 1) / 2;
    }

    public static function easeInBack(x:Float):Float {
        final c1 = 1.70158;
        final c3 = c1 + 1;
        return c3 * x * x * x - c1 * x * x;
    }

    public static function easeOutBack(x:Float):Float {
        final c1 = 1.70158;
        final c3 = c1 + 1;
        return 1 + c3 * Math.pow(x - 1, 3) + c1 * Math.pow(x - 1, 2);
    }

    public static function easeInOutBack(x:Float):Float {
        final c1 = 1.70158;
        final c2 = c1 * 1.525;
        return x < 0.5
            ? (Math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
            : (Math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
    }


    public static function easeInElastic(x:Float):Float {
        final c4 = (2 * Math.PI) / 3;
        
        return x == 0
            ? 0
            : x == 1
            ? 1
            : -Math.pow(2, 10 * x - 10) * Math.sin((x * 10 - 10.75) * c4);
    }

    public static function easeOutElastic(x:Float):Float {
        final c4 = (2 * Math.PI) / 3;
        
        return x == 0
            ? 0
            : x == 1
            ? 1
            : Math.pow(2, -10 * x) * Math.sin((x * 10 - 0.75) * c4) + 1;
    }

    public static function easeInOutElastic(x:Float):Float {
        final c5 = (2 * Math.PI) / 4.5;
        
        return x == 0
            ? 0
            : x == 1
            ? 1
            : x < 0.5
            ? -(Math.pow(2, 20 * x - 10) * Math.sin((20 * x - 11.125) * c5)) / 2
            : (Math.pow(2, -20 * x + 10) * Math.sin((20 * x - 11.125) * c5)) / 2 + 1;
    }

    public static function easeInBounce(x:Float):Float {
        return 1 - easeOutBounce(1 - x);
    }

    public static function easeOutBounce(x:Float):Float {
        final n1 = 7.5625;
        final d1 = 2.75;
        
        if (x < 1 / d1) {
            return n1 * x * x;
        } else if (x < 2 / d1) {
            return n1 * (x -= 1.5 / d1) * x + 0.75;
        } else if (x < 2.5 / d1) {
            return n1 * (x -= 2.25 / d1) * x + 0.9375;
        } else {
            return n1 * (x -= 2.625 / d1) * x + 0.984375;
        }
    }

    public static function easeInOutBounce(x:Float):Float {
        return x < 0.5
            ? (1 - easeOutBounce(1 - 2 * x)) / 2
            : (1 + easeOutBounce(2 * x - 1)) / 2;
    }
}