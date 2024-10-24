package crovown.algorithm;

class StringUtils {
    static public function capitalize(string:String) {
        return string.charAt(0).toUpperCase() + string.substring(1);
    }
}