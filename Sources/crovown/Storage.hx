package crovown;

import haxe.io.Bytes;
#if js
import js.Browser;
#else
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
#end

interface IStorage {
    public function write(label:String, data:String):Void;
    public function read(label:String):String;
    // @todo
    // public function writeBytes(label:String, data:Bytes):Void;
    // public function readBytes(label:String):Bytes;
    // public function delete(label:String):Void;   // @todo
    public function entries():Array<String>;
}

// @todo
class Storage implements IStorage {
    public final function write(label:String, data:String) {

    }

    public final function read(label:String) {
        return "";
    }

    public function entries():Array<String> {
        return [];
    }

    /*
    public function writeBytes(label:String, data:Bytes) {
        
    }

    public function readBytes(label:String) {
        return null;
    }
    */

    public function getPath():Null<String> {
        return null;
    }
}

// @todo на Android не работает

class UserStorage implements IStorage {
    public var folder:String = null;

    public function new(folder = "userdata") {
        this.folder = folder;
    }

    public function write(label:String, data:String) {
        // @todo for android
        #if js
        var storage = Browser.getLocalStorage();
        storage.setItem(label, data);
        #else
        var folder = Path.join([Sys.getCwd(), folder]);
        trace('Saved to $folder');
        if (!FileSystem.isDirectory(folder)) FileSystem.createDirectory(folder);
        var file = File.write(Path.join([folder, label]), false);
        file.writeString(data, UTF8);
        #end
    }

    public function read(label:String) {
        try {
            #if js
            var storage = Browser.getLocalStorage();
            return storage.getItem(label);
            #else
            return File.getContent(Path.join([Sys.getCwd(), folder, label]));
            #end
        } catch (e) {
            trace(e);
            return null;
        }
    }

    /*
    public function writeBytes(label:String, data:Bytes) {
        // @todo for android
        #if js
        var storage = Browser.getLocalStorage();
        storage.setItem(label, data);
        #else
        var folder = Path.join([Sys.getCwd(), folder]);
        trace('Saved to $folder');
        if (!FileSystem.isDirectory(folder)) FileSystem.createDirectory(folder);
        var file = File.write(Path.join([folder, label]), false);
        file.writeBytes(data, 0, data.length);
        #end
    }

    public function readBytes(label:String) {
        return null;
    }
    */

    public function entries():Array<String> {
        #if js
        var storage = Browser.getLocalStorage();
        return [for (i in 0...storage.length) storage.key(i)];
        #else
        return FileSystem.readDirectory(Path.join([Sys.getCwd(), folder]));
        #end
    }
}