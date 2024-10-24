package format.fnt;

import format.fnt.Data;
import format.fnt.Data.Info;
import format.fnt.Data.Common;
import format.fnt.Data.Kerning;
import format.fnt.Data.Page;
import format.fnt.Data.Char;

using StringTools;

class Reader {
    // @todo принимает поток байт или Input (как png)
    public function new() {
        
    }

    // @todo на основе байт
    public function read() {
        // return readBmFont();
    }

    public function readBmFont(source:String):Data {
        var lines = source.split("\n");

        // @todo there is a bug
        // if there is a whitespace betweetn characters in the face section for example,
        // then it will be parsed as a two different statements
        // which causes the next() call and therefore a wrong behaviour
        var r = ~/([^ =,\n\r]+)/ig;

        var string:String = null;
        var index = 0;
        inline function next() {
            if (!r.matchSub(string, index)) return null;
            var value = r.matched(1);
            var pos = r.matchedPos();
            index = pos.pos + pos.len;
            return value;
        }

        inline function nextInt() return Std.parseInt(next());

        var info:Info = {};
        var common:Common = {};
        var page:Page = {};
        var kerning:Kerning = {};
        var chars = new Array<Char>();
        
        for (line in lines) {
            string = line;
            index = 0;
            var tag = next();
            switch (tag) {
                case "info":
                    while (index < line.length) {
                        var v = next();
                        switch (v) {
                            case "face": info.face = next();
                            case "size": info.size = nextInt();
                            case "bold": info.bold = nextInt() != 0;
                            case "italic": info.italic = nextInt() != 0;
                            case "charset": info.charset = next();
                            case "unicode": info.unicode = nextInt();
                            case "stretchH": info.stretchH = nextInt();
                            case "smooth": info.smooth = nextInt();
                            case "aa": info.aa = nextInt();
                            case "padding": info.padding = [nextInt(), nextInt(), nextInt(), nextInt()];
                            case "spacing": info.spacing = [nextInt(), nextInt()];
                            case "outline": info.outline = nextInt();
                            case null: break;
                            default: next();
                        }
                    }
                case "common":
                    while (index < line.length) {
                        var v = next();
                        switch (v) {
                            case "lineHeight": common.lineHeight = nextInt();
                            case "base": common.base = nextInt();
                            case "scaleW": common.scaleW = nextInt();
                            case "scaleH": common.scaleH = nextInt();
                            case "pages": common.pages = nextInt();
                            case "packed": common.packed = nextInt();
                            case "alphaChnl": common.alphaChnl = nextInt();
                            case "redChnl": common.redChnl = nextInt();
                            case "greenChnl": common.greenChnl = nextInt();
                            case "blueChnl": common.blueChnl = nextInt();
                            case null: break;
                            default: next();
                        }
                    }
                case "page":
                    while (index < line.length) {
                        var v = next();
                        switch (v) {
                            case "id": page.id = nextInt();
                            case "file": page.file = next();
                            case null: break;
                            default: next();
                        }
                    }
                case "char":
                    var char = {};
                    chars.push(char);
                    while (index < line.length) {
                        var v = next();
                        switch (v) {
                            case "id": char.id = nextInt();
                            case "x": char.x = nextInt();
                            case "y": char.y = nextInt();
                            case "width": char.width = nextInt();
                            case "height": char.height = nextInt();
                            case "xoffset": char.xoffset = nextInt();
                            case "yoffset": char.yoffset = nextInt();
                            case "xadvance": char.xadvance = nextInt();
                            case "page": char.page = nextInt();
                            case "chnl": char.chnl = nextInt();
                            case null: break;
                            default: next();
                        }
                    }
                case "kerning":
                    // @note Not tested yet
                    while (index < line.length) {
                        var v = next();
                        switch (v) {
                            case "first": kerning.first = nextInt();
                            case "second": kerning.second = nextInt();
                            case "amount": kerning.amount = nextInt();
                            case null: break;
                            default: next();
                        }
                    }
            }
        }
        // trace(info);
        // trace(common);
        // trace(page);
        // for (c in chars) trace(c);
        // trace(kerning);
        return {
            info: info,
            common: common,
            page: page,
            chars: chars,
            kerning: kerning
        }
    }
}