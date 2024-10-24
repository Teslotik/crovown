package crovown.types;

enum abstract Kind(String) from String to String {
    var Component;
    var Application;
    var Window;
    var Animation;
    var Widget;
    var Registry;
    var StageGui;
    var Operation;
    var Factory;
    var Filter;
}