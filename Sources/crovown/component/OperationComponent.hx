package crovown.component;

import crovown.types.Kind;

using Lambda;

// @todo переместить в Crovown
@:build(crovown.Macro.component())
class OperationComponent extends Component {
    @:p public var name:String = "Operation";
    @:p public var description:String = "empty";
    @:p public var onExecute:Component->Bool = null;
    @:p public var data:Component = null;
    // @:p public var record = false;

    public function new() {
        super();
        kind = Kind.Operation;
    }

    static public function build(crow:Crovown, component:OperationComponent) {
        return component;
    }

    public function execute(crow:Crovown, ?data:Component) {
        // @todo делать снапшот программы и добавлять в объект Crovown
        // if (record) crow.record();   // @note записываеть если onExecute() == true?
        onExecute(data ?? this.data);
    }
}