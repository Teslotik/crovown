package crovown.types;

enum abstract Blend(Int) from Int to Int {
    var Normal        = 0;
    var AlphaOver     = 1;
    // var Mask          = 2;   // @todo
    var Dissolve      = 5;
    var Add           = 10;
    var Subtract      = 15;
    var Multiply      = 20;
    var Divide        = 25;
    var Screen        = 30;
    var Exclusion     = 35;
    var Difference    = 40;
    var Power         = 45;
    var Root          = 50;
    var Overlay       = 55;
    var HardLight     = 60;
    var SoftLight     = 65;
    var VividLight    = 70;
    var LinearLight   = 75;
    var Lighten       = 80;
    var Darken        = 85;
    var ColorBurn     = 90;
    var LinearBurn    = 95;
    var ColorDodge    = 100;
    var LinearDodge   = 105;
    var Hue           = 110;
    var Saturation    = 115;
    var Value         = 120;
    var Color         = 125;
}