package crovown.component;

import crovown.types.Kind;

using Lambda;

@:build(crovown.Macro.component())
class FactoryComponent extends Component {
    @:p public var name:String = "Operation";
    @:p public var description:String = "empty";
    @:p public var onExecute:Component->Component = null;
    @:p public var data:Component = null;

    public function new() {
        super();
        kind = Kind.Factory;
    }

    static public function build(crow:Crovown, component:FactoryComponent) {
        return component;
    }

    public function execute(crow:Crovown, ?data:Component) {
        return onExecute(data ?? this.data);
    }
}