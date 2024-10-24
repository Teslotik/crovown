package crovown.types;

enum abstract Priority(Int) from Int to Int {
    var Lowest = 0;
    var Low = 25;
    var Normal = 50;
    var High = 75;
    var Highest = 100;
}