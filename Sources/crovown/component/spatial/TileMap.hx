package crovown.component.spatial;

import crovown.event.LayoutEvent;
import crovown.event.DrawWidgetEvent;
import crovown.backend.Backend.SurfaceShader;
import crovown.component.widget.StageGui;
import crovown.Crovown;
import crovown.component.widget.Widget;

@:build(crovown.Macro.component())
class TileMap extends Widget {
    @:p public var tileset:TileSet = null;
    // @:p public var width = 100;
    // @:p public var height = 100;
    // @:p public var chunk:Int = 16;
    @:p public var size:Int = 16;   // count of tiles in a row/column of the chunk

    // @todo chunks
    // public var tiles:Array<Int> = null;
    public var chunks = new Array<Chunk>();

    public static function build(crow:Crovown, component:TileMap) {
        // @todo
        // component.onWidth.subscribe(component, size -> {
            
        // });

        // component.onHeight.subscribe(component, size -> {
            
        // });

        // component.tiles = [for (i in 0...component.width * component.height) 0];

        return component;
    }

    override function onDrawWidgetEvent(event:DrawWidgetEvent) {
        surface ??= crow.application.backend.shader(SurfaceShader.label);

        event.buffer.pushTransform(world);

        surface.setSurface(tileset.surface);
        event.buffer.setShader(surface);

        for (chunk in chunks) {
            for (i in 0...chunk.tiles.length) {
                var t = chunk.tiles[i];
                // var x = chunk.x * this.chunk + Std.int(i / width);
                // var y = chunk.y * this.chunk + i % width;
                // var x = Std.int(i / width);
                // var y = i % width;
                var tx = Std.int(t / tileset.width);
                var ty = t % tileset.width;
                var w = 1 / tileset.width;
                var h = 1 / tileset.height;
                // trace(x, y, chunk.x, chunk.y);
                var radius = size * tileset.size;
                // event.buffer.drawTile(
                //     (-radius / 2) + (chunk.x * size * tileset.size) + (x * tileset.size),
                //     (-radius / 2) + (chunk.y * size * tileset.size) + (y * tileset.size),
                //     1, 1,
                //     0,
                //     0,
                //     1, 1
                // );
                
                // event.buffer.drawRect(-radius / 2 + chunk.x * size * tileset.size, -radius / 2 + chunk.y * size * tileset.size, radius, radius);

                event.buffer.drawTile(
                    (-radius / 2) + (chunk.x * size * tileset.size) + (i % size * tileset.size),
                    (-radius / 2) + (chunk.y * size * tileset.size) + (Std.int(i / size) * tileset.size),
                    tileset.size, tileset.size,
                    w * tx, 1 - h - h * ty,
                    1 / tileset.width, 1 / tileset.height
                );
            }

            // var w = this.chunk * width;
            // var h = this.chunk * height;
            // event.buffer.drawRect(-w / 2 + chunk.x * w, -h / 2 + chunk.y * h, w, h);
            // event.buffer.drawRect(chunk.x * w, chunk.y * h, w, h);
            //
            // var w = size * tileset.size;
            // var h = size * tileset.size;
            // event.buffer.drawRect(-w / 2 + chunk.x * size * tileset.size, -h / 2 + chunk.y * size * tileset.size, w, h);
        }

        event.buffer.flush();
        event.buffer.popTransform();
    }

    @:eventHandler
    override function onLayoutEvent(event:LayoutEvent) {
        w = size * tileset.size;
        h = size * tileset.size;
        super.onLayoutEvent(event);
    }

    // @todo auto resize?
    public function setTile(x:Int, y:Int, tile:Int) {
        var current:Chunk = null;
        for (chunk in chunks) {
            // if (chunk.x > x) continue;
            // if (chunk.y > y) continue;
            // if (chunk.x + this.chunk < x) continue;
            // if (chunk.y + this.chunk < y) continue;
            
            if (chunk.x * size > x) continue;
            if (chunk.y * size > y) continue;
            if ((chunk.x + 1) * size <= x) continue;
            if ((chunk.y + 1) * size <= y) continue;
            current = chunk;
            break;
        }
        if (current == null) {
            current = {
                x: Math.floor(x / size),
                y: Math.floor(y / size),
                tiles: [for (i in 0...size * size) 0]
            }
            chunks.push(current);
            // trace("------------------- new chunk", "x:", x, "y:", y, "cx:", current.x, "cy:", current.y, current.x * this.chunk - x, current.y * this.chunk - y);
            // trace("new chunk at", current.x, current.y);
        }
        // trace("chunk", "x:", x, "y:", y, "chunk x:", current.x, "chunk y:", current.y, size);
        // trace((x - current.x * size) * width, (y - current.y * size));
        // current.tiles[(x - current.x * this.chunk) * width + (y - current.y * this.chunk)] = tile;
        current.tiles[(x - current.x * size) + (y - current.y * size) * size] = tile;
        // trace((x - current.x * size) * size + (y - current.y * size), tile);
        // trace((x - current.x * size) * size + (y - current.y * size));
        // trace(x, y);


        // trace(x, y, tile);
        // tiles[x * width + y] = tile;
        return this;
    }
}

typedef Chunk = {
    x:Int,
    y:Int,
    tiles:Array<Int>
}