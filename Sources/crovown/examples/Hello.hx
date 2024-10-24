package crovown.examples;

// #if blender400
import crovown.backend.BlenderBackend.BlenderApi;
import crovown.backend.BlenderBackend.Blf;
// import crovown.backend.BlenderBackend.Context as C;
// #end

@:native("Hello") class Hello {
    // #if blender400
    // // var target = new Blender400();
    // #end

    public function new() {
    }
    
    public function hello() {
        trace("Hello, world!");
        var id = Blf.load("/home/sergei/Projects/Crovown3/stuff/Searfont");
        




        // BlenderApi.context.active_object.select_set(false);
        // C.active_object.select_set(false);
        // Context.deselect();
        // new C();
    }
}