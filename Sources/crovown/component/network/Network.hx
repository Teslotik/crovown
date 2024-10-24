package crovown.component.network;

import crovown.types.Operation;
import crovown.algorithm.MathUtils;
import haxe.io.Bytes;
using crovown.component.Component;

// typedef Command = {

// }

@:build(crovown.Macro.component(false))
class Network extends Component {
    @:p public var buffer:Int = 200;

    public var packet:Bytes = null; // @note вынести в ds?
    public var offset(default, null):Int = 0;

    public static function build(crow:Crovown, component:Network) {
        component.packet = Bytes.alloc(component.buffer);

        return component;
    }

    // синхронизация, обновление измененией

    public function send() {
        
    }

    public function addRoute(identifier:String) {
        packet.setInt32(offset, MathUtils.hashString(identifier));
        offset += 4;
        return this;
    }

    public function setIndex(i:Int) {
        packet.setInt32(offset, i);
        offset += 4;
        return this;
    }

    public function setOperation(op:Operation) {
        packet.setInt32(offset, op);
        offset += 4;
        return this;
    }

    public function setPayload(size:Int) {
        packet.setInt32(offset, size);
        offset += 4;
        return this;
    }

    public function setIntValue(v:Int) {
        setPayload(4);
        packet.setInt32(offset, v);
        offset += 4;
        return this;
    }

    public function setFloatValue(v:Float) {
        setPayload(4);
        packet.setFloat(offset, v);
        offset += 4;
        return this;
    }

    public function setBoolValue(v:Bool) {
        setPayload(4);
        packet.setInt32(offset, v ? 1 : 0);
        offset += 4;
        return this;
    }


    public function setStringValue(v:String) {
        var str = Bytes.ofString(v);
        setPayload(str.length);
        packet.blit(offset, str, 0, str.length);
        offset += str.length;
        return this;
    }
}