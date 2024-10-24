package crovown.types;

import crovown.ds.Vector;

enum Action {
    KeyCode(v:KeyCode);
    Char(v:String);
    // Text(v:String);  // @todo
    Axis(id:Int, v:Vector);     // @todo должны ли быть здесь оси? позиция мыши здесь не указывается
    Button(v:Button);
}

enum abstract KeyCode(Int) from Int to Int {
    var Unknown = 0;
    var Ctrl;
    var Shift;
    var Alt;
	var Return;
    var Backspace;
    var Delete;
	var Tab;
	var Escape;
	var Space;
    var Plus;
    var Minus;
    var Left;
    var Right;
    var Up;
    var Down;
    var A;
    var B;
    var C;
    var D;
    var E;
    var F;
    var G;
    var H;
    var I;
    var J;
    var K;
    var L;
    var M;
    var N;
    var O;
    var P;
    var Q;
    var R;
    var S;
    var T;
    var U;
    var V;
    var W;
    var X;
    var Y;
    var Z;
}

enum abstract Button(Int) from Int to Int {
    var Left;
    var Right;
    var Middle;
}