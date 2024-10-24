package crovown.component.widget;

import crovown.algorithm.MathUtils;
import crovown.types.Action;
import crovown.event.DrawWidgetEvent;
import crovown.event.InputEvent;
import crovown.types.Color;

@:build(crovown.Macro.component())
class TextEditWidget extends TextWidget {
    static var eraseLeftWord:Array<Action> = [KeyCode(Ctrl), KeyCode(Backspace)];
    static var eraseLeft:Array<Action> = [KeyCode(Backspace)];
    static var eraseRightWord:Array<Action> = [KeyCode(Ctrl), KeyCode(Delete)];
    static var eraseRight:Array<Action> = [KeyCode(Delete)];
    static var selectAll:Array<Action> = [KeyCode(Ctrl), KeyCode(A)];
    static var selectLeftWord:Array<Action> = [KeyCode(Ctrl), KeyCode(Shift), KeyCode(Left)];
    static var selectLeft:Array<Action> = [KeyCode(Shift), KeyCode(Left)];
    static var selectRightWord:Array<Action> = [KeyCode(Ctrl), KeyCode(Shift), KeyCode(Right)];
    static var selectRight:Array<Action> = [KeyCode(Shift), KeyCode(Right)];
    static var moveCursorLeftWord:Array<Action> = [KeyCode(Ctrl), KeyCode(Left)];
    static var moveCursorLeft:Array<Action> = [KeyCode(Left)];
    static var moveCursorRightWord:Array<Action> = [KeyCode(Ctrl), KeyCode(Right)];
    static var moveCursorRight:Array<Action> = [KeyCode(Right)];
    static var copy:Array<Action> = [KeyCode(Ctrl), KeyCode(C)];
    static var paste:Array<Action> = [KeyCode(Ctrl), KeyCode(V)];

    @:p public var isEditable:Bool = true;
    @:p public var onChange:TextEditWidget->Void;
    @:p public var onFinished:TextEditWidget->Void;
    // @note cursor == 0 - before text, cursor == text.length - last character
    @:p public var cursor:Color = Blue;
    @:p public var selection:Null<Int> = null;
    
    var _pos:Int = 0;
    @:p public var pos(get, set):Int;
    function get_pos() return MathUtils.clampg(_pos, 0, text.length);
    function set_pos(v:Int) return _pos = MathUtils.clampg(v, 0, text.length);

    // @:p public var pos(default, set):Int = 0;
    // function set_pos(v:Int) return pos = MathUtils.clampg(v, 0, text.length);

    public static function build(crow:Crovown, component:TextEditWidget) {
        component.horizontal = Fixed(component.font.getWidth(component.text));
        component.vertical = Fixed(component.font.getHeight(component.text));
        component.texture = crow.application.backend.loadSurface("Inter");  // @todo удалить
        return component;
    }

    override function onDrawWidgetEvent(event:DrawWidgetEvent) {
        super.onDrawWidgetEvent(event);

        if (!isActive || !isEditable) return;

        event.buffer.pushTransform(world);

        // Cursor
        event.buffer.coloredShader.setColor(cursor);
        event.buffer.setShader(event.buffer.coloredShader);
        font.setSize(size);
        var offset = font.getWidth(text, pos);
        event.buffer.drawLine(-w / 2 + offset, -h / 2, -w / 2 + offset, h / 2, 2);
        event.buffer.flush();

        // Selection
        if (selection != null) {
            event.buffer.coloredShader.setColor(cursor & 0x80FFFFFF);
            event.buffer.setShader(event.buffer.coloredShader);
            var pos = pos;
            var selection = selection;
            if (pos < selection) {
                var tmp = selection;
                selection = pos;
                pos = tmp;
            }
            var start = font.getWidth(text, pos);
            var end = font.getWidth(text, selection);
            event.buffer.drawRect(-w / 2 + start, -h / 2, end - start, h);
            event.buffer.flush();
        }

        event.buffer.popTransform();
    }

    @:eventHandler
    override function onInputEvent(event:InputEvent) {
        super.onInputEvent(event);
        if (event.isCancelled) return;

        var area = getArea();

        // Making widget active/inactive
        // and placing the cursor
        if (area.isPressed) {
            isActive = true;
            font.setSize(size);
            pos = font.getPosition(text, event.position.x - x);
            selection = null;
        } else if (area.isDown && !area.wasDown && !area.isOver && isActive) {
            isActive = false;
            if (onFinished != null) onFinished(this);
        }

        if (!isActive || !isEditable) return;

        var isChanged = false;

        // Text input
        switch event.input.justPressed() {
            case Char(v):
                if (selection != null) eraseSelected(pos, selection);
                var begin = text.substring(0, pos);
                var end = text.substring(pos);
                text = begin + v + end;
                pos++;
                isChanged = true;
                selection = null;
            default:
        }

        // @note If you decided to change here something, dont forget about this:
        // - add flag isChanged
        // - handle selection
        // - reset selection

        if (area.isDragging) {
            font.setSize(size);
            selection ??= pos;
            pos = font.getPosition(text, event.position.x - x);
            event.isCancelled = true;
        } else if (event.input.isCombination(eraseLeftWord)) {
            eraseSelected(pos, selection ?? findWord(false));
            isChanged = true;
        } else if (event.input.isCombination(eraseLeft)) {
            eraseSelected(pos, selection ?? pos - 1);
            isChanged = true;
        } else if (event.input.isCombination(eraseRightWord)) {
            eraseSelected(pos, selection ?? findWord());
            isChanged = true;
        } else if (event.input.isCombination(eraseRight)) {
            eraseSelected(pos, selection ?? pos + 1);
            isChanged = true;
        } else if (event.input.isCombination(selectAll)) {
            pos = 0;
            selection = text.length;
            swap();
        } else if (event.input.isCombination(selectLeftWord, false)) {
            selection ??= pos;
            // Offset needed to "add" selection to existed one when spaces are occurred
            pos = findWord(false, pos - 1);
        } else if (event.input.isCombination(selectLeft, false)) {
            selection ??= pos;
            pos--;
        } else if (event.input.isCombination(selectRightWord, false)) {
            selection ??= pos;
            // +1 see above
            pos = findWord(pos + 1);
        } else if (event.input.isCombination(selectRight, false)) {
            selection ??= pos;
            pos++;
        } else if (event.input.isCombination(moveCursorLeftWord)) {
            // Moving the cursor towards start or end of the selection
            // or shifting it if selection is null
            pos = selection == null ? findWord(false) : pos < selection ? pos : selection;
            selection = null;
        } else if (event.input.isCombination(moveCursorLeft)) {
            // See above
            pos = selection == null ? pos - 1 : pos < selection ? pos : selection;
            selection = null;
        } else if (event.input.isCombination(moveCursorRightWord)) {
            // See above
            pos = selection == null ? findWord() : pos > selection ? pos : selection;
            selection = null;
        } else if (event.input.isCombination(moveCursorRight)) {
            // See above
            pos = selection == null ? pos + 1 : pos > selection ? pos : selection;
            selection = null;
        } else if (event.input.isCombination(copy)) {
            // @todo
            isChanged = true;
            selection = null;
        } else if (event.input.isCombination(paste)) {
            // @todo
            isChanged = true;
            selection = null;
        }

        if (isChanged && onChange != null) onChange(this);
        if (isChanged) event.isCancelled = true;
    }

    function findWord(forward = true, ?pos:Int) {
        pos ??= this.pos;
        if (forward) {
            var prev:Null<String> = null;
            for (i in pos...text.length) {
                var char = text.charAt(i);
                if (prev != null && prev != " " && char == " ") return i;
                prev = char;
            }
            return text.length;
        } else {
            var prev:Null<String> = null;
            for (i in 1...pos) {
                var char = text.charAt(pos - i);
                if (prev != null && prev != " " && char == " ") return pos - i + 1;
                prev = char;
            }
            return 0;
        }
    }

    function eraseSelected(start:Int, end:Int) {
        if (text.length == 0) return;
        if (end < start) {
            var tmp = start;
            start = end;
            end = tmp;
        }
        pos = start;
        text = text.substring(0, start) + text.substring(end);
        selection = null;
    }

    function swap(forward = true) {
        if (selection == null) return;
        if (forward && pos > selection) return;
        if (!forward && pos < selection) return;
        var tmp = pos;
        pos = selection;
        selection = tmp;
    }
}