package crovown;

import haxe.macro.Compiler;
import haxe.Rest;
import haxe.io.Bytes;
import crovown.backend.Backend.Font;
import haxe.Json;
import haxe.macro.TypeTools;
#if macro
import sys.io.File;
import sys.FileSystem;
#end
import haxe.macro.Type.FieldKind;
import haxe.macro.Type.ClassField;
import haxe.macro.Expr;
import haxe.macro.Type.AnonType;
import haxe.macro.Expr.Field;
import haxe.macro.Context;
import haxe.macro.Type.ClassType;
import haxe.io.Path;

using Lambda;
using crovown.algorithm.StringUtils;
using StringTools;
using haxe.macro.ComplexTypeTools;

// @todo refactor
#if macro
typedef Property = {
    name:String,
    type:haxe.macro.Type,
    ?expr:haxe.macro.Expr,
    // @todo remove?
    ?canRead:Bool,
    ?canWrite:Bool,
    ?hasSetter:Bool,
    ?get:String,
    ?isProp:Bool,
    ?isSimple:Bool,
    ?isOwning:Bool,
    ?isComponent:Bool,
    ?isSignal:Bool,
    ?isId:Bool,
    ?meta:Array<String>,
    ?cls:String,
    ?getType:() -> haxe.macro.Type
}
#end

class Macro {
    // macro static public function component():Array<Field> {
    //     var fields = Context.getBuildFields();
    //     var extra = new Array<Field>();
    //     var pos = Context.currentPos();
        
    //     var t = Context.toComplexType(Context.getLocalType());
    //     var tp = switch (t) {
    //         case TPath(p): p;
    //         case _: null;
    //     }

    //     var baseFields:Array<ClassField> = [];
    //     var collectFields:Null<ClassType>->Void;
    //     collectFields = cls -> {
    //         if (cls.superClass != null) collectFields(cls.superClass.t.get());
    //         for (field in cls.fields.get()) baseFields.push(field);
    //     }
    //     collectFields(Context.getLocalClass().get());
        
    //     // Creating empty constructor if it doesn't exists
    //     var constructor = fields.find(f -> f.name == "new");
    //     if (constructor == null) {
    //         extra.push({
    //             name: "new",
    //             pos: pos,
    //             access: [APrivate],
    //             kind: FFun({
    //                 args: [],
    //                 expr: macro super()
    //             })
    //         });
    //     } else {
    //         constructor.access = [APrivate];
    //     }
        
    //     // All fields with @:p metadata becomes arguments
    //     var params:Array<Field> = [];
    //     for (field in baseFields) {
    //         if (!field.meta.get().exists(m -> m.name == ":p") || field.meta.get().exists(m -> m.name == "p")) continue;
    //         var kind:FieldType = null;
    //         var canRead = true;
    //         switch (field.kind) {
    //             case FVar(read, write):
    //                 canRead = read == AccNormal || read == AccCall;
    //                 // Variables and properties
    //                 // kind = FVar(Context.toComplexType(field.expr() == null ? field.type : field.expr().t));
    //                 kind = FVar(Context.toComplexType(field.type));
    //             case _: continue;
    //         }
    //         params.push({
    //             name: field.name,
    //             pos: pos,
    //             meta: [{
    //                 name: ":optional",
    //                 pos: pos
    //             }].concat(!canRead ? [] : [{
    //                 name: ":get",
    //                 pos: pos
    //             }]),
    //             kind: kind
    //         });
    //     }
        
    //     for (field in fields) {
    //         if (field.meta == null || !field.meta.exists(m -> m.name == ":p") || field.meta.exists(m -> m.name == "p")) continue;
    //         var kind:FieldType = null;
    //         var canRead = switch field.kind {
    //             case FProp(get, set, t, e): get == "get";
    //             case _: true;
    //         }
    //         switch (field.kind) {
    //             case FVar(t, e) | FProp(_, _, t, e):
    //                 kind = FVar(t ?? Context.toComplexType(Context.typeof(e)));
    //             case _: continue;
    //         }
    //         params.push({
    //             name: field.name,
    //             pos: pos,
    //             kind: kind,
    //             meta: [{
    //                 name: ":optional",
    //                 pos: pos
    //             }].concat(!canRead ? [] : [{
    //                 name: ":get",
    //                 pos: pos
    //             }])
    //         });
    //     }
        
    //     // static function Text(crow:Crovown, params:{text:String}) {}
    //     if (fields.exists(f -> f.name == "build")) {
    //         extra.push({
    //             name: Context.getLocalClass().get().name,
    //             pos: pos,
    //             access: [AStatic, APublic],
    //             kind: FFun({
    //                 args: [{
    //                     name: "crow",
    //                     type: macro: Crovown,
    //                     opt: false
    //                 }].concat(if (params.empty()) [] else [{
    //                     name: "params",
    //                     type: TAnonymous(params),
    //                     opt: true
    //                 }]),
    //                 ret: t,
    //                 // ret: macro: component.Component,
    //                 expr: macro {
    //                     var comp = new $tp();
    //                     comp.kind = $v{Context.getLocalClass().get().name};
    //                     // Identifiers must be applyed before style
    //                     if (params != null) {
    //                         if (params.id != null) comp.id = params.id;
    //                         if (params.label != null) comp.label = params.label;
    //                         if (params.url != null) comp.url = params.url;
    //                         if (params.tags != null) comp.tags = params.tags;
    //                         if (params.props != null) comp.props = params.props;
    //                     }
    //                     crovown.component.Component.onStyle.emit(slot -> slot(comp));
    //                     // Assigning values of the anonymous structure to the component
    //                     if (params != null) {
    //                         $b{[for (param in params) {
    //                             if (param.name != "id" && param.name != "label" && param.name != "url" && param.name != "tags" && param.name != "props")
    //                             macro if ($p{["params", param.name]} != null) {
    //                                 $p{["comp", param.name]} = $p{["params", param.name]};
    //                             }
    //                         }]}
    //                     }
    //                     var builded = build(comp, crow);
    //                     if (builded.onCreate != null) builded.onCreate(builded);
    //                     crovown.component.Component.onBuild.emit(slot -> slot(builded));
    //                     return builded;
    //                 }
    //             })
    //         });
    //     }
        
    //     // @todo undo/redo for params

    //     // Converting parameters of component type to properties to apply setParent
    //     // public var animation(get, set):Animation;
    //     // public function get_animtaion() return _animation;
    //     // public function set_animtaion(v:Animation) return v.setParent(this);
    //     for (field in fields) {
    //         if (field.meta == null || !field.meta.exists(m -> m.name == ":p") || field.meta.exists(m -> m.name == "p")) continue;
    //         var varType = switch (field.kind) {
    //             case FVar(t, e): t ?? Context.toComplexType(Context.typeof(e));
    //             case _: continue;
    //         }
    //         switch (ComplexTypeTools.toType(varType)) {
    //             case TInst(t, params): {
    //                 while (t != null) {
    //                     // Variable type is inherited from Component
    //                     if (t.get().name == "Component") {
    //                         var name = field.name;
    //                         field.name = "_" + field.name;
    //                         var access = field.access;
    //                         field.access = [APrivate];
    //                         // Property
    //                         extra.push({
    //                             name: name,
    //                             pos: pos,
    //                             access: access,
    //                             kind: FProp("get", "set", varType)
    //                         });
                            
    //                         // Getter
    //                         extra.push({
    //                             name: "get_" + name,
    //                             pos: pos,
    //                             access: [],
    //                             kind: FFun({
    //                                 args: [],
    //                                 ret: varType,
    //                                 expr: macro return $i{field.name}
    //                             })
    //                         });

    //                         // Setter
    //                         extra.push({
    //                             name: "set_" + name,
    //                             pos: pos,
    //                             access: [],
    //                             kind: FFun({
    //                                 args: [{
    //                                     name: "v",
    //                                     type: varType
    //                                 }],
    //                                 ret: varType,
    //                                 expr: macro {
    //                                     v.setParent(this);
    //                                     return $i{field.name} = v;
    //                                 }
    //                             })
    //                         });
    //                         break;
    //                     }
    //                     t = t.get().superClass?.t;
    //                 }
    //             }
    //             case _: continue;
    //         }
    //         // extra.push({

    //         // })
    //     }
        
    //     // Making store and load functions
    //     // for (field in fields) {
    //     //     if (field.meta == null || !field.meta.exists(m -> m.name == ":p") || field.meta.exists(m -> m.name == "p")) continue;
    //     //     switch field.kind {
    //     //         case FVar(t, e) | FProp(_, _, t, e): {
    //     //             trace(macro: Int, t);
    //     //             if (t.equals(macro: Int)) trace(field.name);
    //     //             // case Context.toComplexType(macro: Int): {
    //     //             //     trace(field.name);
    //     //             // }
    //     //             // case _: null;
    //     //             // trace(field.name, ComplexTypeTools.toType(t));
    //     //             // trace(field.name, t);
    //     //             // switch ComplexTypeTools.toType(t) {
    //     //             //     // case 
    //     //             //     // case (macro: Int) {
    //     //             //     //     trace(field.name, "Int");
    //     //             //     // }
    //     //             // }
    //     //         }
    //     //         case _: null;
    //     //     }
    //     // }

    //     var expr = new Array<Expr>();
    //     for (param in params) {
    //         // if (field.meta == null || !field.meta.exists(m -> m.name == ":p") || field.meta.exists(m -> m.name == "p")) continue;
    //         // switch param.kind {
    //         //     case FProp(get, set, t, e): if (get != "get") continue;
    //         //     case _: null;
    //         // }
    //         if (!param.meta.exists(m -> m.name == ":get")) continue;
    //         switch param.kind {
    //             case FVar(t, e) | FProp(_, _, t, e): {
    //                 var a = t?.toType() ?? Context.typeof(e);
    //                 if (Std.string(ComplexTypeTools.toType(macro: Bool)) == Std.string(a)) {
    //                     // expr.push(macro data.set(makePath(label + "." + $v{param.name}, root), VBool($i{param.name})));
    //                     expr.push(macro data.set(makePath(label + "." + $v{param.name}, root), $i{param.name}));
    //                 } else if (Std.string(ComplexTypeTools.toType(macro: Int)) == Std.string(a)) {
    //                     // expr.push(macro data.set(makePath(label + "." + $v{param.name}, root), VInt($i{param.name})));
    //                     expr.push(macro data.set(makePath(label + "." + $v{param.name}, root), $i{param.name}));
    //                 } else if (Std.string(ComplexTypeTools.toType(macro: Float)) == Std.string(a)) {
    //                     // expr.push(macro data.set(makePath(label + "." + $v{param.name}, root), VFloat($i{param.name})));
    //                     expr.push(macro data.set(makePath(label + "." + $v{param.name}, root), $i{param.name}));
    //                 } else if (Std.string(ComplexTypeTools.toType(macro: String)) == Std.string(a)) {
    //                     // expr.push(macro data.set(makePath(label + "." + $v{param.name}, root), VString($i{param.name})));
    //                     expr.push(macro data.set(makePath(label + "." + $v{param.name}, root), $i{param.name}));
    //                 } else {
    //                     expr.push(macro {
    //                         var variants = makeSimple($v{param.name});
    //                         if (variants != null) {
    //                             for (i in 0...variants.length) {
    //                                 data.set(makePath(label + "." + $v{param.name} + '[${i}]', root), variants[i]);
    //                             }
    //                         }
    //                     });
    //                 }
    //             }
    //             case _: null;
    //         }
    //     }
    //     extra.push({
    //         name: "store",
    //         pos: pos,
    //         access: [APublic, AOverride],
    //         kind: FFun({
    //             args: [{
    //                 name: "root",
    //                 type: macro: String,
    //                 opt: true
    //             }],
    //             ret: macro: Map<String, Dynamic>,
    //             expr: macro {
    //                 var data = new Map<String, Dynamic>();
    //                 $b{expr}
    //                 return data;
    //             }
    //         }),
    //     });



    //     return fields.concat(extra);
    // }

    #if macro
    public static function isID(name:String) {
        if (name == "id") return true;
        if (name == "label") return true;
        if (name == "url") return true;
        if (name == "tags") return true;
        if (name == "props") return true;
        return false;
    }
    #end

    #if macro
    public static function isSignal(name:String) {
        return name.startsWith("on");
    }
    #end

    macro public static function getContent(pathname:String) {
        return macro $v{File.getContent(pathname)};
    }

    macro public static function getBytes(pathname:String) {
        return macro $v{File.getBytes(pathname)};
    }

    #if macro
    macro public static function assets(isRecursive:Bool = true, load:Array<String>):Array<Field> {
        var fields = Context.getBuildFields();
        var pos = Context.currentPos();
        
        var files = [];
        function read(absolute:String, relative:Array<String>) {
            var entries = FileSystem.isDirectory(absolute) ? FileSystem.readDirectory(absolute) : [absolute];
            for (entry in entries) {
                var abs = Path.join([absolute, entry]);
                if (FileSystem.isDirectory(abs)) {
                    if (isRecursive) read(abs, relative.concat([entry]));
                } else {
                    files.push({
                        entry: Path.withoutDirectory(abs),
                        absolute: abs,
                        relative: relative
                    });
                }
            }
        }
        if (load != null) {
            for (pathname in load) read(FileSystem.absolutePath(pathname), []);
        }

        fields.push({
            name: "jsons",
            access: [APublic, AStatic, AFinal],
            kind: FVar(macro: Map<String, Dynamic>, macro new Map<String, Dynamic>()),
            pos: pos
        });

        fields.push({
            name: "fonts",
            access: [APublic, AStatic, AFinal],
            kind: FVar(macro: Map<String, crovown.backend.Backend.Font>, macro new Map<String, crovown.backend.Backend.Font>()),
            pos: pos
        });

        fields.push({
            name: "images",
            access: [APublic, AStatic, AFinal],
            kind: FVar(macro: Map<String, crovown.ds.Image>, macro new Map<String, crovown.ds.Image>()),
            pos: pos
        });

        // Reading files
        for (path in files) {
            var label = Path.withoutExtension(path.entry);
            var id = path.relative.concat([label]).join("_").replace(" ", "_");   // @todo rename
            switch (Path.extension(path.entry)) {
                case "json":
                    var json = Json.parse(File.getContent(path.absolute));
                    fields.push({
                        name: "json_" + id,
                        access: [APublic, AStatic, AFinal],
                        kind: FVar(macro: Dynamic, macro {
                            var json = $v{json};
                            jsons.set($v{label}, $v{json});
                            json;
                        }),
                        pos: pos
                    });
                case "fnt":
                    var content = File.getContent(path.absolute);
                    // @todo pass parsed data or file source
                    // Context.addResource(id, content);
                    fields.push({
                        name: "font_" + id,
                        access: [APublic, AStatic, AFinal],
                        kind: FVar(macro: crovown.backend.Backend.Font, macro {
                            var font = new crovown.backend.Backend.Font($v{label}).loadFnt($v{content});
                            fonts.set($v{label}, font);
                            font;
                        }),
                        pos: pos
                    });
                case "png":
                    var stream = File.read(path.absolute);
                    var data = new format.png.Reader(stream).read();
                    var header = format.png.Tools.getHeader(data);
                    var bytes = format.png.Tools.extract32(data, null, true);
                    for (i in 0...Std.int(bytes.length / 4)) {
                        var b = bytes.get(i * 4 + 0);
                        var r = bytes.get(i * 4 + 2);
                        bytes.set(i * 4 + 0, r);
                        bytes.set(i * 4 + 2, b);
                    }
                    Context.addResource(id, bytes);
                    fields.push({
                        name: "image_" + id,
                        access: [APublic, AStatic, AFinal],
                        kind: FVar(macro: crovown.ds.Image, macro {
                            var image:crovown.ds.Image = {
                                w: $v{header.width},
                                h: $v{header.height},
                                data: haxe.Resource.getBytes($v{id})
                            }
                            images.set($v{label}, image);
                            image;
                        }),
                        pos: pos
                    });
                    stream.close();
            }
        }

        
        
        return fields;
    }
    #end

    #if macro
    macro public static function plugin(autoLoad:Bool = false):Array<Field> {
        var fields = Context.getBuildFields();
        var pos = Context.currentPos();

        var tp = switch (Context.toComplexType(Context.getLocalType())) {
            case TPath(p): p;
            default: null;
        }
        
        var field = Context.getLocalClass().get().name;
        fields.push({
            name: "register",
            access: [APrivate, AStatic],
            kind: FFun({
                args: [],
                ret: macro: String,
                expr: macro {
                    var code = $v{tp.pack.join(".") + "." + tp.name}
                    crovown.plugin.Plugin.factory.set(code, crow -> {
                        try {
                            var instance = new $tp();
                            instance.isAutoLoadable = $v{autoLoad};
                            instance.label = $v{tp.name};
                            instance.crow = crow;
                            instance.onCreate(crow);
                            instance.onCreated.emit(slot -> slot(instance));
                            return instance;
                        } catch (e) {
                            crovown.Crovown.onPluginException.emit(slot -> slot(null, code, e));
                        }
                        return null;
                    });
                    return code;
                }
            }),
            pos: pos,
            meta: []
        });
        
        fields.push({
            name: "code",
            access: [AStatic, APrivate],
            kind: FVar(macro: String, macro register()),
            pos: pos,
            meta: []
        });

        return fields;
    }
    #end

    #if macro
    macro public static function event():Array<Field> {
        var fields = Context.getBuildFields();
        var pos = Context.currentPos();
        var cls = Context.getLocalClass().get();
        var isRoot = cls.superClass == null;

        // public static final type:String = "Event";
        fields.push({
            name: "type",
            access: [APublic, AStatic, AFinal],
            kind: FVar(macro: String, macro $v{cls.name}),
            pos: pos
        });

        // override public function getType() return type;
        fields.push({
            name: "getType",
            access: [APublic].concat(isRoot ? [] : [AOverride]),
            kind: FFun({
                args: [],
                ret: macro: String,
                expr: macro return type,
            }),
            pos: pos
        });

        // public static final hash:Int = crovown.algorithm.MathUtils.hashString("Event");
        fields.push({
            name: "hash",
            access: [APublic, AStatic, AFinal],
            kind: FVar(macro: Int, macro crovown.algorithm.MathUtils.hashString($v{cls.name})),
            pos: pos
        });

        // override public function getHash() return hash;
        fields.push({
            name: "getHash",
            access: [APublic].concat(isRoot ? [] : [AOverride]),
            kind: FFun({
                args: [],
                ret: macro: Int,
                expr: macro return hash,
            }),
            pos: pos
        });

        return fields;
    }
    #end

    @:keep
    macro static public function buildinfo():Array<Field> {
        var fields = Context.getBuildFields();

        // @todo
        // #if macro
        // trace(FileSystem.absolutePath(""));
        // var q = File.getContent("Sources/buildinfo.json");
        // trace(q);
        // #end


        // trace("-=-=-=--=-=-=-=-=-=-=-=-", Context.getAllModuleTypes());
        // trace(Context.resolvePath());
        // trace(Context.storeExpr());

        // Context.onAfterInitMacros(() -> {
        //     trace("ssssssssssssss");
        // });

        return fields;
    }

    // @todo refactor

    #if macro
    // @todo передавать в генераторы готовые подборки переменных (allprops, basefields)
    macro public function component(undo:Bool = false, ?settings:{?signals:Bool, ?isVisible:Bool}):Array<Field> {
        Compiler.registerCustomMetadata({
            metadata: ":eventHandler",
            doc: "Registers function as an event handler"
        });

        var pos = Context.currentPos();
        var cls = Context.getLocalClass().get();
        var fields = Context.getBuildFields();
        var extra = new Array<Field>();

        // ---------------------------- Data ----------------------------
        var t = Context.toComplexType(Context.getLocalType());
        var tp = switch (t) {
            case TPath(p): p;
            case _: null;
        }
        var build = fields.find(f -> f.name == "build");
        var constructor = fields.find(f -> f.name == "new");
        var canParent = fields.find(f -> f.name == "canParent");
        var canChild = fields.find(f -> f.name == "canChild");
        
        // ---------------------------- Flags ----------------------------
        var isRoot = cls.superClass == null;
        
        // ---------------------------- Checks ----------------------------
        var wrong = fields.find(f -> (!f.kind.match(FVar(_, _)) && !f.kind.match(FProp(_, _))) && f.meta.exists(m -> m.name == ":p"));
        if (wrong != null) {
            Context.error('Only variables and properties can be marked with @:p metadata: ${cls.name}.${wrong.name}', pos);
        }

        // ---------------------------- Collections ----------------------------
        function collect(cls:ClassType, f:ClassType->ClassField->Void) {
            if (cls.superClass != null) collect(cls.superClass.t.get(), f);
            for (field in cls.fields.get()) f(cls, field);
        }
        
        var props = new Array<Property>();
        for (field in fields) {
            if (!field.meta.exists(m -> m.name == ":p")) continue;
            switch (field.kind) {
                case FVar(t, e):
                    props.push({
                        name: field.name,
                        type: t?.toType() ?? Context.typeof(e),
                        expr: e,
                        canRead: true,
                        canWrite: true,
                        isProp: false,
                        isOwning: true,
                        meta: [for (f in field.meta) f.name],
                        cls: (cls.pack.concat([cls.name]).join(".")),
                        getType: () -> t?.toType() ?? Context.typeof(e)
                    });
                case FProp(get, set, t, e):
                    props.push({
                        name: field.name,
                        type: t?.toType() ?? Context.typeof(e),
                        expr: e,
                        canRead: get == "default" || get == "null" || get == "get" || get == "dynamic",
                        canWrite: set == "default" || set == "null" || set == "set" || set == "dynamic",
                        hasSetter: set == "set" || set == "dynamic",
                        get: get,
                        isProp: true,
                        isOwning: true,
                        meta: [for (f in field.meta) f.name],
                        cls: (cls.pack.concat([cls.name]).join(".")),
                        getType: () -> t?.toType() ?? Context.typeof(e)
                    });
                default: continue;
            }
        }
        // Context.getLocalType().
        cls.meta.add(":ready", [], pos);
        // trace("\n\n", cls.name);
        collect(cls, (cls, field) -> {
            // Context.info(cls.name + ", " + field.name, pos);
            // if (cls.name == "TextWidget") trace(field.name, [for (m in field.meta.get()) m.name], field.meta.get().exists(m -> m.name == ":p"), props.exists(f -> f.name == field.name));
            // trace([for (m in cls.meta.get()) m.name]);
            // trace(cls.meta.has(":ready"));
            if (!cls.meta.has(":ready")) return;
            if (!field.meta.get().exists(m -> m.name == ":p")) return;
            if (props.exists(f -> f.name == field.name)) return;
            switch (field.kind) {
                case FVar(r, w):
                    // if (r.match(AccInline) || w.match(AccInline)) return;
                    // var expr = field.expr(); //
                    // var expr = field.type == null ? null : field.expr();


                    // switch (field.type) {
                    //     case TLazy(f): if (false) f();
                    //     default: trace(field.name);
                    // }
                    var getType = switch (field.type) {
                        case TLazy(f): f;
                        default: () -> field.type;
                    }
                    // var toString = switch (field.type) {
                    //     case TLazy(f): ;
                    //     default: () -> field.type;
                    // }
                    // trace()

                    // if (!field.meta.has(":ready")) return;





                    // var meta = field.meta.get().find(m -> m.name == ":rt");
                    // if (meta == null) return;
                    // var typename = switch (meta.params[0].expr) {
                    //     case EConst(c):
                    //         switch (c) {
                    //             case CString(s, kind): s;
                    //             // case CString(s, kind): trace(field.name, s);
                    //             default: return;
                    //         };
                    //     default: return;
                    // }
                    // var type:haxe.macro.Type = null;
                    // if (field.name == "children") {
                    //     // type = (macro: Array<crovown.component.Component>).toType();
                    // } else {
                    //     try {
                    //         // type = Context.getType(typename);
                    //     } catch (_) {
                    //         // type = (macro: Dynamic).toType();
                    //     }
                    // }


                    // var type = field.type ?? Context.typeof(Context.getTypedExpr(field.expr()));
                    // var type = null;

                    // /*
                    props.push({
                        name: field.name,
                        // type: (macro: Dynamic).toType(),
                        // type: switch (field.type) {
                        //     case TLazy(f): f();
                        //     default: return;
                        // },
                        // type: type,
                        type: null,
                        expr: null,
                        canRead: r.match(AccNormal) || r.match(AccNo) || r.match(AccCall),
                        canWrite: w.match(AccNormal) || w.match(AccNo) || w.match(AccCall),
                        hasSetter: w.match(AccCall),
                        isProp: false,  // @todo
                        isOwning: false,
                        // meta: [for (f in field.meta.get()) f.name]   //
                        cls: cls.name,
                        getType: getType
                    });
                    // */
                    //
                    /*
                    props.push({
                        name: field.name,
                        type: field.type ?? Context.typeof(Context.getTypedExpr(expr)),
                        expr: expr != null ? Context.getTypedExpr(expr) : null,
                        canRead: r.match(AccNormal) || r.match(AccNo) || r.match(AccCall),
                        canWrite: w.match(AccNormal) || w.match(AccNo) || w.match(AccCall),
                        hasSetter: w.match(AccCall),
                        isProp: false,  // @todo
                        isOwning: false,
                        meta: [for (f in field.meta.get()) f.name]
                    });
                    */
                default:
            }
        });
        
        for (prop in props) {
            prop.isSignal = prop.name.startsWith("on");
            prop.isId = prop.name == "id" || prop.name == "label" || prop.name == "url" || prop.name == "tags" || prop.name == "props";
            prop.isSimple =
                Std.string(ComplexTypeTools.toType(macro: Bool)) == Std.string(prop.type) ||
                Std.string(ComplexTypeTools.toType(macro: Int)) == Std.string(prop.type) ||
                Std.string(ComplexTypeTools.toType(macro: Float)) == Std.string(prop.type) ||
                Std.string(ComplexTypeTools.toType(macro: String)) == Std.string(prop.type);
            prop.isComponent = false;
            //
            // /*
            if (!prop.isOwning) continue;
            switch (prop.type) {
                case TInst(t, params):
                    while (t != null) {
                        if (t.get().name == "Component") {
                            prop.isComponent = true;
                            // trace("----------------", prop.name, "is component");
                        }
                        t = t.get().superClass?.t;
                    }
                case null:
                default:
            }
            // */
        }
        // trace("");
        // trace(cls.name);
        // for (p in props) trace(p);



        // ---------------------------- Adding fields ----------------------------

        // extra.push({
        //     name: "__inst__",
        //     access: [APublic, AStatic],
        //     kind: FVar(t),
        //     pos: pos
        // });

        constructor == null ? extra.push(setupConstructor(constructor)) : setupConstructor(constructor);

        if (canParent == null) {
            extra.push({
                name: "canParent",
                access: [APublic, AStatic],
                kind: FFun({
                    args: [{
                        name: "component",
                        type: macro: crovown.component.Component,
                    }],
                    ret: macro: Bool,
                    expr: macro return true
                }),
                pos: pos
            });
        }

        if (canChild == null) {
            extra.push({
                name: "canChild",
                access: [APublic, AStatic],
                kind: FFun({
                    args: [{
                        name: "component",
                        type: macro: crovown.component.Component,
                    }],
                    ret: macro: Bool,
                    expr: macro return true
                }),
                pos: pos
            });
        }

        var signals = generateSignals(fields, props, undo, settings?.signals ?? true);
        if (build != null) {
            if (!build.meta.exists(m -> m.name == ":noUsing")) {
                build.meta.push({
                    name: ":noUsing",
                    pos: pos
                });
            }
            extra.push(generateFactory(props, t, tp));
            extra.push(generateRebuild(t, isRoot));

            extra.push({
                name: "callFactory",
                access: isRoot ? [APublic] : [APublic, AOverride],
                kind: FFun({
                    args: [{
                        name: "crow",
                        type: macro: crovown.Crovown
                    }],
                    ret: macro: crovown.component.Component,
                    expr: macro return $i{Context.getLocalClass().get().name}(crow)
                }),
                pos: pos
            });
        }
        
        // public static final type = "TextWidget";
        extra.push({
            name: "type",
            access: [APublic, AStatic, AFinal],
            kind: FVar(macro: String, macro $v{cls.name}),
            pos: pos
        });
        // override public function getType() return type;
        extra.push({
            name: "getType",
            access: [APublic].concat(isRoot ? [] : [AOverride]),
            kind: FFun({
                args: [],
                ret: macro: String,
                expr: macro return type,
            }),
            pos: pos
        });
        // public var generateHistory:Bool = undo;
        extra.push({
            name: "generateHistory",
            access: [APrivate, AStatic],
            kind: FVar(macro: Bool, macro $v{undo}),
            pos: pos
        });
        // @todo в команду передаётся code и инстанцирование происходит автоматически
        // в builder передаётся готовый инстанс
        extra.push(generateCommand(props, isRoot));
        // см. коммент выше
        extra.push(generateCommandPacked(props, isRoot));
        extra.push(generateStore(props, isRoot, tp));
        extra.push(generateLoad(props, isRoot));
        generateCode(extra, settings?.isVisible ?? true, build != null);
        
        // for (f in signals) f.meta = [{
        //     name: ":p",
        //     pos: pos
        // }];
        // var signals:Array<Field> = [];
        // for (p in props) {
        //     if (!p.isOwning) continue;
        //     extra.push({
        //         name: '__${p.name}__',
        //         access: [APublic, AStatic],
        //         kind: FVar(Context.toComplexType(p.type)),
        //         pos: pos,
        //     });
        // }



        // @:eventHandler function onLayoutEvent(event:LayoutEvent)
        // ->
        // handlers = ["DrawEvent" => onDrawEvent, "LayoutEvent" => onLayoutEvent]
        extra.push({
            name: "subscribe",
            access: isRoot ? [APublic] : [AOverride, APublic],
            kind: FFun({
                args: [{
                    name: "label",
                    type: macro: String
                }, {
                    name: "callback",
                    type: macro: crovown.event.Event->Void
                }],
                ret: macro: Void,
                expr: macro handlers.set(crovown.algorithm.MathUtils.hashString(label), callback),
            }),
            pos: pos
        });
        extra.push({
            name: "registerHandlers",
            access: isRoot ? [APrivate] : [AOverride, APrivate],
            kind: FFun({
                args: [],
                ret: macro: Void,
                expr: macro {
                    $e{if (!isRoot) macro super.registerHandlers() else macro null}
                    // var map = new Map<Int, crovown.event.Event->Void>();
                    $b{[for (field in fields) {
                        if (!field.meta.exists(m -> m.name == ":eventHandler")) continue;
                        switch field.kind {
                            case FFun(f):
                                if (f.args.length != 1) {
                                    Context.error('Event handler ${field.name} must have one argument', pos);
                                    continue;
                                }
                                switch f.args[0].type {
                                    case TPath(p):
                                        macro subscribe($v{p.name}, cast($i{field.name}));
                                        // macro handlers.set(crovown.algorithm.MathUtils.hashString($v{p.name}), cast($i{field.name}));
                                    default: continue;
                                }
                            case _: continue;
                        }
                    }]}
                    // return map;
                }
            }),
            pos: pos
        });

        var fields = fields.filter(f -> !extra.exists(e -> e.name == f.name) && !signals.exists(s -> s.name == f.name));

        for (f in fields.concat(extra).concat(signals)) {
            /*
            var complex = switch (f.kind) {
                case FVar(t, e): t ?? Context.toComplexType(Context.typeof(e));
                case FProp(get, set, t, e): t ?? Context.toComplexType(Context.typeof(e));
                default: continue;
            }
            // complex.
            var tp = switch (complex) {
                case TPath(p): p;
                case _: null;
            }
            var name:Null<String> = switch (complex.toType()) {
                case TInst(t, params): t.get().name;
                // case TType(t, params): t.get().name;
                case TAbstract(t, params): t.get().name;
                case TEnum(t, params): t.get().name;
                case q: "";
            }
            // switch (complex.toType()) {
            //     case TInst(t, params): trace(tp.pack, tp.sub, complex.toString(), t.get().name);
            //     // case TType(t, params): trace(t.get().name);
            //     case TAbstract(t, params): trace(t.get().name);
            //     case TEnum(t, params): trace(t.get().name);
            //     case q: "";
            // }
            
            // trace(tp?.name, tp);
            // var name:String = tp?.name ?? "";
            // Context.
            if (f.meta == null) {
                f.meta = [{
                    name: ":rt",
                    params: [macro $v{name}],
                    // params: [macro new $tp()],
                    pos: pos
                }];
            } else {
                f.meta.push({
                    name: ":rt",
                    params: [macro $v{name}],
                    // params: [macro new $tp()],
                    // params: [{
                    //     expr: EConst(CString(tp?.name)),
                    //     pos: pos
                    // }],
                    pos: pos
                });
            }
            */
        }
        return fields.concat(signals).concat(extra);
    }
    #end

    #if macro
    public static function setupConstructor(constructor:Field):Field {
        var pos = Context.currentPos();
        
        // Creating an empty constructor if it doesn't exists
        constructor ??= {
            name: "new",
            pos: pos,
            access: [APrivate],
            kind: FFun({
                args: [],
                ret: null,
                expr: macro {
                    super();
                }
            }),
            meta: []
        }
        constructor.access = [APrivate];
        
        return constructor;
    }
    #end

    #if macro
    public static function generateSignals(fields:Array<Field>, props:Array<Property>, undo:Bool, signals:Bool):Array<Field> {
        var pos = Context.currentPos();
        var access:Array<Access> = [APublic];

        var extra = new Array<Field>();

        for (prop in props) {
            if (prop.isId || prop.isSignal || !prop.isOwning) continue;

            var field = fields.find(f -> f.name == prop.name);
            var t = Context.toComplexType(prop.type);

            // var onName:Signal<String->Void> = new Signal<String->Void>();
            extra.push({
                name: "on" + prop.name.capitalize(),
                access: access,
                kind: FVar(macro: crovown.ds.Signal<$t->Void>, macro new crovown.ds.Signal<$t->Void>()),
                pos: pos
            });

            if (!prop.isProp) {
                // var name(defautl, set):String;
                extra.push({
                    name: prop.name,
                    access: access,
                    kind: FProp("default", "set", t, prop.expr),
                    pos: pos,
                    meta: [for (m in prop.meta) {
                        name: m,
                        pos: pos
                    }]
                });
                // function set_name(v:String) { onName.emit(slot->slot(v)); return v; }
                extra.push({
                    name: 'set_${prop.name}',
                    kind: FFun({
                        args: [{
                            name: "v",
                            type: t
                        }],
                        ret: t,
                        expr: generateSetter(prop.name, prop.isComponent, signals)
                    }),
                    pos: pos
                });

            } else {
                if (prop.hasSetter) {
                    // function set_name(v:String) { onName.emit(slot->slot(v)); /** code **/ }
                    var setter = fields.find(f -> f.name == "set_" + field.name);
                    switch (setter.kind) {
                        case FFun(f):
                            switch (f.expr.expr) {
                                case EBlock(exprs):
                                    exprs.unshift(macro $i{"on" + prop.name.capitalize()}.emit(slot -> slot($i{f.args[0].name})));
                                default:
                            }
                        default:
                    }
                    continue;
                }
                
                if (prop.canWrite) {
                    // function set_name(v:String) { onName.emit(slot->slot(v)); return v; }
                    extra.push({
                        name: 'set_${prop.name}',
                        kind: FFun({
                            args: [{
                                name: "v",
                                type: t
                            }],
                            ret: t,
                            expr: generateSetter(prop.name, prop.isComponent, signals)
                        }),
                        pos: pos
                    });
                    field.kind = FProp(prop.get, "set", t, prop.expr);
                }
            }
        }
        return extra;
    }
    #end

    #if macro
    static function generateSetter(name:String, hasComponentParent:Bool, signals = true) {
        return macro {
            ${if (signals) macro $i{"on" + name.capitalize()}.emit(slot -> slot(v)) else macro null}

            var __temp_value__ = $i{name};
            ${if (hasComponentParent) {
                macro {
                    if (generateHistory) {
                        var __temp_parent__ = v?.parent;
                        crow.record(makePath($v{name}), crow -> {
                            var isLocked = crow.isHistoryLocked;
                            crow.isHistoryLocked = true;
                            if (v != null) v.parent = this;
                            crow.isHistoryLocked = isLocked;
                            $i{name} = v;
                        }, crow -> {
                            var isLocked = crow.isHistoryLocked;
                            crow.isHistoryLocked = true;
                            if (v != null) v.parent = __temp_parent__;
                            crow.isHistoryLocked = isLocked;
                            $i{name} = __temp_value__;
                        });
                        var isLocked = crow.isHistoryLocked;
                        crow.isHistoryLocked = true;
                        if (v != null) v.parent = this;
                        crow.isHistoryLocked = isLocked;
                    } else {
                        var isLocked = crow.isHistoryLocked;
                        crow.isHistoryLocked = true;
                        if (v != null) v.parent = this;
                        crow.isHistoryLocked = isLocked;
                    }
                }
            } else {
                macro {
                    if (generateHistory) {
                        crow.record(makePath($v{name}),
                            crow -> $i{name} = v,
                            crow -> $i{name} = __temp_value__
                        );
                    }
                }
            }}
            return $p{["this", name]} = v;
        }
    }
    #end


    #if macro
    public static function generateFactory(props:Array<Property>, ?t:ComplexType, ?tp:TypePath):Field {
        var pos = Context.currentPos();

        var meta:Metadata = [{
            name: ":optional",
            pos: pos
        }];
        return {
            name: Context.getLocalClass().get().name,
            access: [APublic, AStatic],
            pos: pos,
            kind: FFun({
                args: [{
                    name: "crow",
                    type: macro: crovown.Crovown,
                    opt: false
                }, {
                    name: "builder",
                    type: macro: $t->Void,
                    opt: true
                }, {
                    name: "params",
                    // @note All fields taken from the Component class
                    type: TAnonymous([{
                        name: "id",
                        kind: FVar(macro: Int),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "label",
                        kind: FVar(macro: String),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "url",
                        kind: FVar(macro: String),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "tags",
                        kind: FVar(macro: List<String>),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "props",
                        kind: FVar(macro: Map<String, Dynamic>),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "isEnabled",
                        kind: FVar(macro: Bool),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "isActive",
                        kind: FVar(macro: Bool),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "children",
                        kind: FVar(macro: Array<crovown.component.Component>),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "animation",
                        kind: FVar(macro: crovown.component.animation.Animation),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "onRebuild",
                        kind: FVar(macro: crovown.component.Component->Void),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "onCreate",
                        kind: FVar(macro: crovown.component.Component->Void),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "onReady",
                        kind: FVar(macro: crovown.component.Component->Void),
                        pos: pos,
                        meta: meta
                    }, {
                        name: "onDestroy",
                        kind: FVar(macro: crovown.component.Component->Void),
                        pos: pos,
                        meta: meta
                    }]),
                    opt: true
                }, {
                    name: "ch",
                    // type: macro: haxe.extern.Rest<crovown.component.Component>,
                    type: macro: Array<crovown.component.Component>,
                    opt: true
                }],
                ret: t,
                expr: macro {
                    var locked = crow.isHistoryLocked;
                    crow.isHistoryLocked = true;
                    var comp = new $tp();
                    comp.crow = crow;
                    comp.builder = cast builder;
                    if (comp.kind == Application) {
                        crow.application = cast comp;
                    } else if (crow.application == null) {
                        // @todo удалить и сделать чтобы приложения сами устанавливали себя в crow во время обновления
                        trace("[Warning] First instanced component MUST be Application");
                    }
                    // Assigning values of the anonymous structure to the component
                    if (params != null) {
                        if (params.id != null) comp.id = params.id;
                        if (params.label != null) comp.label = params.label;
                        if (params.url != null) comp.url = params.url;
                        if (params.tags != null) comp.tags = params.tags;
                        if (params.props != null) comp.props = params.props;
                        if (params.isEnabled != null) comp.isEnabled = params.isEnabled;
                        if (params.isActive != null) comp.isActive = params.isActive;
                        // comp.children = params.children == null ? ch : params.children.concat(ch);
                        if (params.children == null) {
                            comp.children = ch ?? [];
                        } else {
                            comp.children = ch == null ? params.children : params.children.concat(ch);
                        }
                        if (params.animation != null) comp.animation = params.animation;
                        if (params.onRebuild != null) comp.onRebuild = params.onRebuild;
                        if (params.onCreate != null) comp.onCreate = params.onCreate;
                        if (params.onReady != null) comp.onReady = params.onReady;
                        if (params.onDestroy != null) comp.onDestroy = params.onDestroy;
                    } else {
                        // comp.children = ch;
                        comp.children = ch ?? [];
                    }
                    // if (comp.label == "layer") trace("----------------------------");
                    // if (comp.label == "layer") trace(cast(comp, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    if (builder != null) builder(comp);
                    // if (comp.label == "layer") trace(cast(comp, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    crovown.component.Component.onRule.emit(slot -> slot(comp));
                    // if (comp.label == "layer") trace(cast(comp, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    var builded = build(crow, comp);
                    // if (comp.label == "layer") trace(cast(comp, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    if (!builded.isBuilded && builded.onCreate != null) builded.onCreate(builded);
                    // if (comp.label == "layer") trace(cast(comp, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    if (!builded.isBuilded && builded.onReady != null) crow.application.delay(app -> builded.onReady(builded));
                    // if (comp.label == "layer") trace(cast(comp, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    builded.isBuilded = true;
                    crovown.component.Component.onBuild.emit(slot -> slot(builded));
                    // if (comp.label == "layer") trace(cast(comp, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    // if (comp.label == "layer") trace("----------------------------");
                    crow.isHistoryLocked = locked;
                    return builded;
                }
            })
        }
    }

    #end




    /*
    #if macro
    public static function generateFactory(props:Array<Property>, ?t:ComplexType, ?tp:TypePath):Field {
        var pos = Context.currentPos();

        // @todo only writable
        // var params:Array<Field> = [for (p in props) {
        //     name: p.name,
        //     kind: FVar(Context.toComplexType(p.type)),
        //     // kind: FVar(Context.toComplexType(Context.makeMonomorph())),
        //     pos: pos,
        //     meta: [{
        //         name: ":optional",
        //         pos: pos
        //     }]
        // }];

        var params = [for (p in props) {
            name: p.name
        }];

        // trace(TAnonymous([for (p in props) {
        //     name: p.name,
        //     kind: FVar(Context.toComplexType(Context.makeMonomorph()), macro $p{["this", p.name]}),
        //     pos: pos,
        // }]));

        // trace(TAnonymous([for (p in props) {
        //     name: p.name,
        //     kind: FVar(null),
        //     pos: pos,
        // }]));

        

        // Context.

        // for (p in props) {
        //     trace(p.cls, p.name);
        // }
        
        // static function Text(crow:Crovown, params:{text:String}) {}
        return {
            name: Context.getLocalClass().get().name,
            pos: pos,
            access: [APublic, AStatic],
            kind: FFun({
                // args: [{
                //     name: "crow",
                //     type: macro: crovown.Crovown,
                //     opt: false
                // }].concat(if (params.empty()) [] else [{
                //     name: "params",
                //     type: TAnonymous(params),
                //     type: Context.toComplexType(Context.makeMonomorph()),
                //     opt: true
                // }]),
                
                // var a:haxe.macro.Type = TMono({
                //     get: p,
                //     toString: "toString"
                // })
                args: [{
                    name: "crow",
                    type: macro: crovown.Crovown,
                    opt: false
                }, {
                    name: "params",
                    // type: Context.toComplexType(Context.makeMonomorph()),
                    type: TAnonymous([for (p in props) {
                        name: p.name,
                        // kind: FVar(Context.toComplexType(TMono({
                        //     get: p.getType,
                        //     toString: () -> ""
                        //     // toString: () -> 
                        // }))),
                        kind: FVar(Context.toComplexType(TMono(null))),
                        pos: pos
                    }]),
                    // type: null,
                    // type: TAnonymous([for (p in props) {
                    //     var pp = p.cls.split(".");
                    //     pp.push("__inst__");
                    //     // pp.push('__${p.name}__');
                    //     // trace(p.cls, '__${p.name}__', pp);
                    //     {
                    //         name: p.name,
                    //         // kind: FVar(Context.toComplexType(Context.makeMonomorph()), macro $p{["this", p.name]}),
                    //         // kind: FVar(Context.toComplexType(Context.makeMonomorph())),
                    //         // kind: FVar(null),
                    //         // kind: FVar(macro: Dynamic),
                    //         // kind: FVar(macro: Any),
                    //         kind: FVar(Context.toComplexType(Context.typeof(macro null))),
                    //         // kind: null,
                    //         // kind: FVar(p.type == null ? macro: Dynamic : Context.toComplexType(p.type)),
                    //         // kind: FVar(TNamed(p.name, null)),
                    //         // kind: FVar(Context.toComplexType(Context.typeof(macro $p{pp}))),
                    //         // kind: FVar(Context.toComplexType(Context.typeof(macro $i{"__inst__"}))),
                    //         // kind: FVar(Context.toComplexType(Context.typeof(macro new $tp().id))),
                    //         // kind: FVar(Context.toComplexType(Context.typeof(macro $p{[Context.getLocalClass().get().name, "__inst__", p.name]}))),
                    //         pos: pos,
                    //         meta: [{
                    //             name: ":optional",
                    //             pos: pos
                    //         }]
                    //     }
                    // }]),
                    opt: true
                }],
                ret: t,
                // ret: macro: component.Component,
                expr: macro {
                    // $e{{
                    //     [for (p in props) Context.unify(Context.typeof(macro $p{["params", p.name]}), Context.typeof(macro $p{["this", p.name]}))];
                    //     null;
                    // }}
                    var comp = new $tp();
                    // $e{{[for (p in props) Context.unify(Context.typeof(macro params.$(p.name)), Context.typeof(macro $p{["comp", p.name]}))]; null;}}
                    comp.crow = crow;
                    if (comp.kind == Application) {
                        crow.application = cast comp;
                    } else if (crow.application == null) {
                        // @todo удалить и сделать чтобы приложения сами устанавливали себя в crow во время обновления
                        trace("WARNING! First instanced component MUST be Application");
                    }
                    // comp.type = $v{Context.getLocalClass().get().name};
                    // Identifiers must be applyed before style
                    if (params != null) {
                        if (params.id != null) comp.id = params.id;
                        if (params.label != null) comp.label = params.label;
                        if (params.url != null) comp.url = params.url;
                        if (params.tags != null) comp.tags = params.tags;
                        if (params.props != null) comp.props = params.props;
                    }
                    crovown.component.Component.onRule.emit(slot -> slot(comp));
                    // Assigning values of the anonymous structure to the component
                    //
                    // if (params != null) {
                    //     $b{[for (param in params) {
                    //         if (param.name != "id" && param.name != "label" && param.name != "url" && param.name != "tags" && param.name != "props")
                    //         macro if ($p{["params", param.name]} != null) {
                    //             $p{["comp", param.name]} = $p{["params", param.name]};
                    //         }
                    //     }]}
                    // }
                    var builded = build(crow, comp);
                    if (builded.onCreate != null) builded.onCreate(builded);
                    if (builded.onReady != null) crow.application.delay(app -> builded.onReady(builded));
                    crovown.component.Component.onBuild.emit(slot -> slot(builded));
                    return builded;
                    // return null;
                }
            })
        };
    }
    #end
    */

    #if macro
    public static function generateRebuild(?t:ComplexType, isRoot = false):Field {
        var pos = Context.currentPos();
        return {
            name: "rebuild",
            access: isRoot ? [APublic] : [AOverride, APublic],
            kind: FFun({
                args: [{
                    name: "crow",
                    type: macro: crovown.Crovown
                }],
                ret: t,
                expr: macro {
                    var locked = crow.isHistoryLocked;
                    crow.isHistoryLocked = true;
                    for (child in children) {
                        child.rebuild(crow);
                    }
                    dispose();
                    var component = build(crow, this);
                    crow.isHistoryLocked = locked;
                    return component;
                }
            }),
            pos: pos
        }
    }
    #end

    #if macro
    // @todo rename variables
    public static function generateCommand(props:Array<Property>, isRoot:Bool):Field {
        var pos = Context.currentPos();
        return {
            name: "command",
            access: isRoot ? [APublic] : [AOverride, APublic],
            kind: FFun({
                args: [{
                    name: "command",
                    type: macro: String
                }, {
                    name: "builder",
                    opt: true,
                    type: macro: String->crovown.component.Component
                }],
                ret: macro: Void,
                expr: macro {
                    // @todo remove unnecessary
                    var r = ~/(".+")|([0-9]+\.[0-9]+)|([a-z0-9\[\]=\+\-]+)/ig;
                    var isArray = ~/[a-z0-9]+\[[0-9]+\]/g;
                    var isBool = ~/true|false/g;
                    var isFloat = ~/[0-9]+\.[0-9]+/g;
                    var isInt = ~/[0-9]+/g;
                    var isString = ~/".+"/ig;
                    var isInst = ~/[A-Z][a-zA-Z0-9]+/g;
                    var isIdentifier = ~/[a-z0-9]+/ig;


                    // @todo
                    // function nextInt() {
                    //     return v;
                    // }


                    // r.match(command);
                    // trace(command, r.matched(0));

                    // Tests
                    // label1.label2.title = "sda28.9"
                    
                    // Параллельная иерархия
                    // label1.label2.animation = Animation
                    // label1.label2.animation.label = "slider"
                    
                    // Вставка детей
                    // label1.label2.children[0] += label3
        
                    // Замена детей
                    // label1.label2.children[0] = label3
        
                    // Удаление детей
                    // label1.label2.children[0] = null
                    // label1.label2.children -= label3
                    
                    // @upd старые комментарии, нужно проверить
                    // до тех пор, пока идентификатор - вызываем команду
                    // идентифкатор является либо ребёнок, либо переменная наследованная от компонента
                    // если это не идентификатор, то считается переменной и к ней происходит присваивание

                    // если значение простое - парсим и присваиваем его
                    // если значение-компонент - вызываем фабрику
                    // если переменная массив и операция равенства, заменяем ребёнка на фабрику
                    // если переменная массив и операция добавления, вставляем ребёнка из фабрики
                    // если переменная массив и операция вычитания, удаляем i'того ребёнка

                    

                    // trace("-------- a");

                    r.match(command);
                    var match = r.matched(0);

                    // If identifier is a field and is Component
                    // then passing rest of the command to them
                    $b{[for (prop in props) if (prop.isComponent) macro {
                        if ($v{prop.name} == match) {
                            $p{["this", prop.name, "command"]}(r.matchedRight(), builder);
                            return;
                        }
                    }]}

                    // If identifier is a child
                    // then passing rest of the command to the child
                    var component = Lambda.find(children, c -> c.label == match);
                    if (component != null) {
                        component.command(r.matchedRight(), builder);
                        return;
                    }

                    // If identifier nor child neither Component property
                    // then parsing and assigning it

                    // trace("-------- f");
                    // Идентификатор не компонент, а переменная - присваиваем
                    // var identifier = match;
                    // var operation = r.matched(1);
                    // var value = r.matched(2);

                    isIdentifier.match(command);
                    var identifier = isIdentifier.matched(0);
                    isInt.match(command);
                    var index:Null<Int> = null;
                    if (isArray.match(command)) {
                        index = Std.parseInt(isInt.matched(0));
                    }
                    command = r.matchedRight();
                    r.match(command);
                    var operation = r.matched(0);
                    command = r.matchedRight();
                    r.match(command);
                    var value = r.matched(0);
                    // trace("~~~~~~~~~~~~", command, value);

                    // r.match(command);
                    // trace("=======", r.matched(0));
                    // trace("=======", r.matched(1));
                    // trace("=======", r.matched(2));
                    
                    // trace("-------- h");
                    
                    // trace("-------- i");

                    // trace("-------- j");
                    $b{[for (field in props) {
                        if (!field.isOwning || field.isComponent) continue;
                        var stringify = Std.string(field.type);
                        if (field.name == "children") {
                            // trace("children", Context.getLocalClass().get().name);
                            // macro null;
                            // @todo arrays
                            macro {
                                if (identifier == $v{field.name} && operation == "-=") removeChildBy(c -> c.label == value);
                                $b{[
                                    macro if (identifier == $v{field.name} && operation == "=") replaceChildAt(index, builder(value)),
                                    macro if (identifier == $v{field.name} && operation == "+=") insertChild(index, builder(value)),
                                    // macro if (identifier == $v{field.name} && operation == "-=") removeChildAt(index)
                                ]}
                            }
                        } else if (Std.string((macro: Bool).toType()) == stringify || Std.string((macro: Null<Bool>).toType()) == stringify) {
                            macro {
                                if (identifier == $v{field.name}) $p{["this", field.name]} = value == "true";
                            }
                        } else if (Std.string((macro: Int).toType()) == stringify || Std.string((macro: Null<Int>).toType()) == stringify) {
                            macro {
                                if (identifier == $v{field.name}) $p{["this", field.name]} = Std.parseInt(value);
                            }
                        } else if (Std.string((macro: Float).toType()) == stringify || Std.string((macro: Null<Float>).toType()) == stringify) {
                            macro {
                                if (identifier == $v{field.name}) $p{["this", field.name]} = Std.parseFloat(value);
                            }
                        } else if (Std.string((macro: String).toType()) == stringify || Std.string((macro: Null<String>).toType()) == stringify) {
                            macro {
                                if (identifier == $v{field.name}) $p{["this", field.name]} = value;
                            }
                        } else {
                            // Unsupported type
                            // Context.warning('Property was not recognized: ${field.name}', pos);
                            macro null;
                        }
                    }]}
                }
            }),
            pos: pos
        }
    }
    #end

    // @todo rename variables
    #if macro
    public static function generateCommandPacked(props:Array<Property>, isRoot:Bool):Field {
        var pos = Context.currentPos();
        return {
            name: "commandPacked",
            access: isRoot ? [APublic] : [AOverride, APublic],
            kind: FFun({
                args: [{
                    name: "command",
                    type: macro: haxe.io.Bytes
                }, {
                    name: "builder",
                    opt: true,
                    type: macro: String->crovown.component.Component
                }, {
                    name: "offset",
                    type: macro: Int,
                    value: macro 0
                }],
                ret: macro: Void,
                expr: macro {
                    // label1.label2.title = "sda28.9"
                    
                    // Параллельная иерархия
                    // label1.label2.animation = Animation
                    // label1.label2.animation.label = "slider"
                    
                    // Вставка детей
                    // label1.label2.children[0] += label3
        
                    // Замена детей
                    // label1.label2.children[0] = label3
        
                    // Удаление детей
                    // label1.label2.children[0] = null
                    // label1.label2.children -= label3
                    
                    // @todo
                    // function nextInt() {
                    //     var v = command.getInt32(offset);
                    //     offset += 4;
                    //     return v;
                    // }
                    

                    // @upd старые комментарии, нужно проверить
                    // до тех пор, пока идентификатор - вызываем команду
                    // идентифкатор является либо ребёнок, либо переменная наследованная от компонента
                    // если это не идентификатор, то считается переменной и к ней происходит присваивание

                    // если значение простое - парсим и присваиваем его
                    // если значение-компонент - вызываем фабрику
                    // если переменная массив и операция равенства, заменяем ребёнка на фабрику
                    // если переменная массив и операция добавления, вставляем ребёнка из фабрики
                    // если переменная массив и операция вычитания, удаляем i'того ребёнка

                    // static final map = ${for (p in props) macro crovown.algorithm.MathUtils.hashString($v{p.name}) => };

                    var match = command.getInt32(offset);
                    // trace(match);

                    // trace("-------- b");

                    // If identifier is a field and is Component
                    // then passing rest of the command to them
                    $b{[for (prop in props) if (prop.isComponent) macro {
                        if ($v{crovown.algorithm.MathUtils.hashString(prop.name)} == match) {
                            $p{["this", prop.name, "commandPacked"]}(command, builder, offset + 4);
                            return;
                        }
                    }]}

                    // If identifier is a child
                    // then passing rest of the command to the child
                    var component = Lambda.find(children, c -> crovown.algorithm.MathUtils.hashString(c.label) == match);
                    if (component != null) {
                        component.commandPacked(command, builder, offset + 4);
                        return;
                    }

                    // If identifier nor child neither Component property
                    // then parsing and assigning it



                    // id1 id2 id3 index opertion payload value
                    var identifier = command.getInt32(offset);
                    offset += 4;
                    var index = command.getInt32(offset);
                    offset += 4;
                    var operation = command.getInt32(offset);
                    offset += 4;
                    var payload = command.getInt32(offset);
                    offset += 4;
                    // @todo
                    // var value =
                    // trace(identifier, index, operation, offset, payload);



                    $b{[for (field in props) {
                        if (!field.isOwning || field.isComponent) continue;
                        var stringify = Std.string(field.type);

                        if (field.name == "children") {
                            // macro null;
                            // @todo arrays
                            macro {
                                var value = command.getString(offset, payload, UTF8);
                                // Remove = 2, Assign = 0, Insert = 3
                                if (identifier == $v{crovown.algorithm.MathUtils.hashString(field.name)} && operation == 2) removeChildBy(c -> c.label == value);
                                $b{[
                                    macro if (identifier == $v{crovown.algorithm.MathUtils.hashString(field.name)} && operation == 0) replaceChildAt(index, builder(value)),
                                    macro if (identifier == $v{crovown.algorithm.MathUtils.hashString(field.name)} && operation == 3) insertChild(index, builder(value)),
                                    // macro if (identifier == $v{crovown.algorithm.MathUtils.hashString(field.name) && operation == "-=") removeChildAt(index)
                                ]}
                            }
                        } else if (Std.string((macro: Bool).toType()) == stringify || Std.string((macro: Null<Bool>).toType()) == stringify) {
                            macro {
                                if (identifier == $v{crovown.algorithm.MathUtils.hashString(field.name)}) $p{["this", field.name]} = command.getInt32(offset) != 0;
                            }
                        } else if (Std.string((macro: Int).toType()) == stringify || Std.string((macro: Null<Int>).toType()) == stringify) {
                            macro {
                                if (identifier == $v{crovown.algorithm.MathUtils.hashString(field.name)}) $p{["this", field.name]} = command.getInt32(offset);
                            }
                        } else if (Std.string((macro: Float).toType()) == stringify || Std.string((macro: Null<Float>).toType()) == stringify) {
                            macro {
                                if (identifier == $v{crovown.algorithm.MathUtils.hashString(field.name)}) $p{["this", field.name]} = command.getFloat(offset);
                            }
                        } else if (Std.string((macro: String).toType()) == stringify || Std.string((macro: Null<String>).toType()) == stringify) {
                            macro {
                                if (identifier == $v{crovown.algorithm.MathUtils.hashString(field.name)}) $p{["this", field.name]} = command.getString(offset, payload, UTF8);
                            }
                        } else {
                            // Unsupported type
                            // Context.warning('Property was not recognized: ${field.name}', pos);
                            macro null;
                        }
                    }]}
                    // offset += 4;
                }
            }),
            pos: pos
        }
    }
    #end

    #if macro
    public static function generateStore(fields:Array<Property>, isRoot = false, tp:TypePath):Field {
        return {
            name: "store",
            access: isRoot ? [APublic] : [AOverride, APublic],
            kind: FFun({
                args: [{
                    name: "local",
                    type: macro: Bool,
                    value: macro false,
                }],
                ret: macro: Dynamic,
                expr: macro {
                    var data:Dynamic = {};

                    // trace("========== STORING =============");

                    data.kind = this.kind;
                    data.__name__ = $v{tp.name};
                    data.__pack__ = $v{tp.pack};
                    data.code = code;
                    $b{[for (f in fields) {
                        
                        // @todo types from ds

                        macro {
                            var value = $p{["this", f.name]};

                            $e{if (f.name == "label") {
                                // @todo all identifiers
                                macro {
                                    $p{["data", f.name]} = value;
                                }
                            } else if (f.name == "animation") {
                                macro {
                                    if (!local && value != null) {
                                        $p{["data", f.name]} = value.store(local);
                                    }
                                }
                            } else if (f.name == "children") {
                                // macro {
                                //     switch (simplify($v{f.name})) {
                                //         case Some(v):
                                //             // trace("simplified", $v{f.name}, v);
                                //             $p{["data", f.name]} = v;
                                //         case None:
                                //             // trace("null", $v{f.name});
                                //             null;
                                //     }
                                // }
                                macro {
                                    $p{["data", "children"]} = [for (c in children) c.store(local)];
                                }
                            } else if (Std.string(f.type) == Std.string(ComplexTypeTools.toType(macro: crovown.ds.Rectangle))) {
                                macro {
                                    if (value != null) {
                                        $p{["data", f.name]} = value.serialize();
                                    }
                                }
                            } else if (Std.string(f.type) == Std.string(ComplexTypeTools.toType(macro: crovown.types.Color)) ||
                                Std.string(f.type) == Std.string(ComplexTypeTools.toType(macro: crovown.types.Blend))) {
                                macro {
                                    $p{["data", f.name]} = Std.int(value);
                                }
                            } else if (f.isSimple) {
                                macro {
                                    // trace("simple", $v{f.name}, value);
                                    $p{["data", f.name]} = value;
                                }
                            } else if (f.isComponent) {
                                macro {
                                    if (!local && value != null) {
                                        // trace("comp", $v{f.name}, value);
                                        $p{["data", f.name]} = value.store(local);
                                    }
                                }
                            } else {
                                macro {
                                    // if (value != null) {
                                        
                                    // }
                                    switch (serialize($v{f.name})) {
                                        case Some(v):
                                            // trace("simplified", $v{f.name}, v);
                                            $p{["data", f.name]} = v;
                                        case None:
                                            // trace("null", $v{f.name});
                                            null;
                                    }
                                }
                            }}
                        }
                    }]}
                    return data;
                }
            }),
            pos: Context.currentPos(),
            meta: []
        }
    }
    #end

    #if macro
    public static function generateLoad(fields:Array<Property>, isRoot = false):Field {
        return {
            name: "load",
            access: isRoot ? [APublic] : [APublic, AOverride],
            kind: FFun({
                args: [{
                    name: "crow",
                    type: macro: crovown.Crovown,
                }, {
                    name: "data",
                    type: macro: Dynamic
                }, {
                    name: "builder",
                    opt: true,
                    type: macro: crovown.component.Component->Void
                }],
                ret: macro: crovown.component.Component,
                expr: macro {
                    if (data == null) return this;
                    
                    var locked = crow.isHistoryLocked;
                    crow.isHistoryLocked = true;
                    // trace("========== LOADING =============");

                    // var code = data.get("code");
                    // trace($v{"" + Context.getModule("crovown.component.Component")});
                    $b{[for (f in fields) {
                        macro {
                            var value:Dynamic = $p{["data", f.name]};
                            // trace($v{f.name}, value);
                            $e{if (f.name == "label") {
                                // @todo all identifiers
                                macro {
                                    label = value;
                                }
                            } else if (f.name == "animation") {
                                macro {
                                    if (value != null) {
                                        var comp = crovown.component.Component.factory.get(value.code).builder(crow);
                                        // var comp = crovown.component.Component.factory.get(value.code);
                                        // trace("--------", child.get("id"));
                                        comp.load(crow, value, builder);
                                        animation = cast(comp);
                                    }
                                }
                            } else if (f.name == "children") {
                                macro {
                                    // children = [];
                                    // removeChildren();
                                    // for (child in cast(value, Array<Dynamic>)) {
                                    //     var comp = crovown.component.Component.factory.get(child.code).builder(crow);
                                    //     // var comp = crovown.component.Component.factory.get(child.code);
                                    //     // trace("--------", child.get("id"));
                                    //     trace(comp, child, child.code, builder);
                                    //     comp.load(crow, child, builder);
                                    //     children.push(comp);
                                    // }
                                }
                            } else if (Std.string(f.type) == Std.string(ComplexTypeTools.toType(macro: crovown.ds.Rectangle))) {
                                macro {
                                    if (value != null) {
                                        $p{["this", f.name]} = new crovown.ds.Rectangle().deserialize(value);
                                    }
                                }
                            } else if (Std.string(f.type) == Std.string(ComplexTypeTools.toType(macro: crovown.types.Color)) ||
                                Std.string(f.type) == Std.string(ComplexTypeTools.toType(macro: crovown.types.Blend))) {
                                macro {
                                    $p{["this", f.name]} = value;
                                }
                            } else if (f.isSimple) {
                                macro {
                                    $p{["this", f.name]} = value;
                                }
                            } else if (f.isComponent) {
                                macro {
                                    // if (value == null || value == "") {
                                    //     // $p{["this", f.name]} = null;
                                    // }
                                    if (value != null) {
                                        var comp = crovown.component.Component.factory.get(value.code).builder(crow);
                                        comp.load(crow, value, builder);
                                        $p{["this", f.name]} = cast comp;
                                    }
                                }
                            } else {
                                macro {
                                    if (value != null) {
                                        deserialize($v{f.name}, value);
                                    }
                                    // trace("sssssssssssssssssss", $v{f.name});
                                    // $p{["this", f.name]} = value;
                                    // null;
                                }
                            }}
                        }
                    }]}

                    removeChildren();
                    for (child in cast(data.children, Array<Dynamic>)) {
                        var comp = crovown.component.Component.factory.get(child.code).builder(crow);
                        // var comp = crovown.component.Component.factory.get(child.code);
                        // trace("--------", child.get("id"));
                        comp.load(crow, child, builder);
                        // children.push(comp);
                        addChild(comp);
                    }

                    // trace("------------------------");
                    // if (this.label == "layer") trace(cast(this, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    // callFactory(crow);
                    // if (this.label == "layer") trace(cast(this, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    crovown.component.Component.onRule.emit(slot -> slot(this));
                    // build(crow, this);
                    // $p{[Context.getLocalClass().get().name, "build"]}(crow, this);
                    // $i{Context.getLocalClass().get().name}(crow);
                    $e{
                        if (fields.exists(i -> i.name == Context.getLocalClass().get().name)) macro $i{Context.getLocalClass().get().name}(crow);
                        else macro null
                    }
                    if (builder != null) builder(this);
                    // if (this.label == "layer") trace(cast(this, crovown.component.widget.TreeWidget.TreeItem).vertical);
                    // trace("------------------------");

                    crow.isHistoryLocked = locked;
                    return this;
                }
            }),
            pos: Context.currentPos(),
            meta: []
        }
    }
    #end

    #if macro
    public static function generateCode(fields:Array<Field>, isVisible:Bool, hasBuild:Bool) {
        var pos = Context.currentPos();

        var tp = switch (Context.toComplexType(Context.getLocalType())) {
            case TPath(p): p;
            default: null;
        }
        // data.set("__name__", $v{tp.name});
        // data.set("__pack__", $v{tp.pack});

        var field = Context.getLocalClass().get().name;
        // trace(field);
        fields.push({
            name: "register",
            access: [APrivate, AStatic],
            kind: FFun({
                args: [],
                ret: macro: String,
                expr: macro {
                    var code = $v{tp.pack.join(".") + "." + tp.name}
                    // trace("" + $v{[Context.getLocalClass().get().name, Context.getLocalClass().get().name]});
                    // crovown.component.Component.factory.set(code, crow -> $p{[Context.getLocalClass().get().name, Context.getLocalClass().get().name]}(crow));
                    // crovown.component.Component.factory.set(code, crow -> $i{field}.$field(crow));
                    // crovown.component.Component.factory.set(code, crow -> $field.$field(crow));
                    // crovown.component.Component.factory.set(code, crow -> {
                    //     var comp = new $tp();
                    //     comp.crow = crow;
                    //     return comp;
                    // });
                    // trace($v{field});
                    crovown.component.Component.factory.set(code, {
                        name: $v{field},
                        isVisible: $v{isVisible},
                        builder: crow -> {
                            // var comp = new $tp();
                            // comp.crow = crow;
                            // comp.callFactory(crow);
                            var comp = $e{hasBuild ? macro $i{field}(crow) : macro null};
                            return comp;
                        },
                        canParent: canParent,
                        canChild: canChild
                    });
                    // crovown.component.Component.factory.set(code, crow -> $p{["crow", field]}());
                    // trace("" + $p{[Context.getLocalClass().get().name, Context.getLocalClass().get().name]});

                    // crovown.component.Component.factory.set(code, crow -> crovown.component.network.Network.Network(crow));
                    return code;
                }
            }),
            pos: pos,
            meta: []
        });
        
        fields.push({
            name: "code",
            access: [AStatic, APrivate],
            kind: FVar(macro: String, macro register()),
            pos: pos,
            meta: []
        });
    }
    #end

    // public static function generatePath():Field {
    //     var pos = Context.currentPos();

    //     return {
    //         name: "find",
    //         access: [APublic].concat(Context.getLocalClass().get().name == "Component" ? [] : [AOverride]),
    //         kind: FFun({
    //             args: [{
    //                 name: "path",
    //                 type: macro: String
    //             }],
    //             ret: macro: Component,
    //             expr: macro {
                    
                    
                    
    //                 var current = this;
    //                 for (component in path.split("/")) {
    //                     var up = 0;
    //                     while (up < component.length && component.charAt(up) == ".") {
    //                         up++;
    //                         current = current.parent;
    //                         if (current == null) return null;
    //                     }
    //                     if (up > 0) continue;
    //                     if (current.children.empty()) return null;
    //                     current = if (component == "") current.children[0] else current.children.find(c -> c.label == component);
    //                     if (current == null) return null;
    //                 }
    //             }
    //         }),
    //         pos: pos
    //     }

    //     // return macro null;
    // }

    // static function addBeforeReturn(expr:Expr, call:Expr):Expr {
    //     switch (expr.expr) {
    //         case EReturn(e):
    //             trace("------------");
    //             switch (e.expr) {
    //                 case EConst(c):
    //                     trace("added", c);
    //                 default:
    //             }
    //         case EArray(e1, e2):
    //             addBeforeReturn(e1, call);
    //             addBeforeReturn(e2, call);
    //         case EBlock(exprs):
    //             for (e in exprs) addBeforeReturn(e, call);
    //             // trace(e);
    //             // addBeforeReturn(e, call);
    //         default:
    //     }
    //     return null;
    // }
}
