package crovown.ds;

class Area extends Rectangle {
    public var isOver = false;
    public var isDown = false;
    public var wasDown = false; // @todo rename
    public var isPressed = false;
    public var isReleased = false;
    
    public var isEntered = false;
    public var isExit = false;
    public var isHolding = false;

    public var isDragging = false;
    public var dragStarted = false;
    public var isDropped = false;
    public var drag = new Vector();

    public var mouse = new Vector();
    public var mouseLocal = new Vector();
    public var mouseDelta = new Vector();

    var support = new Vector();

    public static function Corners(left:Float, top:Float, right:Float, bottom:Float) {
        return new Area().setCorners(left, top, right, bottom);
    }

    public static function Center(x:Float, y:Float, xr:Float, yr:Float) {
        return new Area(x - xr, y - yr, x + xr, y + yr);
    }

    override public function toString() {
        return "{" +
            'isOver: ${isOver}, ' +
            'isDown: ${isDown}, ' +
            'wasDown: ${wasDown}, ' +
            'isPressed: ${isPressed}, ' +
            'isReleased: ${isReleased}, ' +
            'isEntered: ${isEntered}, ' +
            'isExit: ${isExit}, ' +
            'isHolding: ${isHolding}, ' +
            'isDragging: ${isDragging}, ' +
            'isDropped: ${isDropped}, ' +
            'drag: ${drag}, ' +
            'mouse: ${mouse}, ' +
            'mouseDelta : ${mouseDelta}' +
        "}";
    }

    public function update(x:Float, y:Float, isDown:Bool) {
        var wasOver = isOver;
        var wasDragging = isDragging;
        
        // Press checks
        isOver = isInside(x, y);
        isPressed = isOver && isDown && !this.isDown;
        isReleased = !isDown && wasDown;

        if (isDown) {
            wasDown = wasDown || isOver && !this.isDown;
        } else {
            wasDown = false;
        }

        this.isDown = isDown;
        
        // Area checks
        isEntered = !wasOver && isOver;
        isExit = wasOver && !isOver;
        
        // Holding
        isHolding = this.isDown && !wasDown;

        // Drag checks
        if (isPressed) drag.set(x, y);
        isDragging = wasDown && (Math.abs(drag.x - x) > 3 || Math.abs(drag.y - y) > 3);
        isDropped = wasDragging && !isDragging;
        dragStarted = !wasDragging && isDragging;
        
        // Mouse
        mouseDelta.set(x - mouse.x, y - mouse.y);
        mouse.set(x, y);
        mouseLocal.set(x - left - w / 2, y - top - h / 2);

        return true;
    }

    public function toLocal(x:Float, y:Float) {
        return support.set(x - (left + right) / 2, y - (top + bottom) / 2);
    }
}