package crovown.backend;

// import lime.utils.ArrayBufferView;
import crovown.backend.Backend.BlurDirectionalShader;
import crovown.backend.Backend.MaskShader;
import crovown.backend.Backend.Input;
import lime.utils.UInt32Array;
// import lime.utils.Int32Array;
import lime.utils.UInt8Array;
import haxe.io.Bytes;
import crovown.ds.Assets;
// import lime.utils.Int8Array;
import crovown.backend.Backend.Mouse;
import crovown.ds.GradientPoint;
import crovown.backend.Backend.GradientShader;
import crovown.backend.Backend.Font;
import lime.graphics.Image;
import crovown.backend.Backend.SdfShader;
import crovown.backend.Backend.OutlineShader;
import crovown.types.Color;
import crovown.algorithm.MathUtils;
import crovown.ds.Vector;
import crovown.ds.Box;
import crovown.backend.Backend.SurfaceShader;
import crovown.backend.Backend.ColoredShader;
import crovown.backend.Backend.MixShader;
import crovown.backend.Backend.AdjustColorShader;
import crovown.ds.Rectangle;
import crovown.algorithm.Geometry;
import lime.utils.Float32Array;
import lime.math.Matrix4;
import crovown.ds.Matrix;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.OpenGLRenderContext;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.OpenGLES3RenderContext;
import crovown.backend.Backend.Shader;
// import lime.utils.ArrayBuffer;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.graphics.opengl.GLProgram;
import lime.graphics.RenderContext;
import lime.graphics.opengl.GL;
import crovown.backend.Backend.Surface;
import crovown.types.Blend;

using Lambda;
using StringTools;
using crovown.algorithm.StringUtils;
// using lime.utils.ArrayBufferView;

/*
@note

*/

// typedef LimeContext = {

// }

@:allow(crovown.backend.LimeBackend)
class LimeContext {
    public static var active(default, null):LimeContext = null;

    #if lime_opengl
	public static var gl(default, null):OpenGLRenderContext = null;
    #elseif lime_webgl
	public static var gl(default, null):WebGL2RenderContext = null;
    #elseif lime_opengles
	public static var gl(default, null):OpenGLES3RenderContext = null;
	#end
    public var structure:AttributeStructure = null;

    public function new() {
        
    }
}

class LimeBackend extends Backend {
    // #if (native && desktop)
	// public static var gl(default, null):OpenGLRenderContext;
    // #elseif (js && html5)
	// public static var gl(default, null):WebGL2RenderContext;
    // #elseif (native)
	// public static var gl(default, null):OpenGLES3RenderContext;
	// #end

    //
    #if lime_opengl
	public static var gl(default, null):OpenGLRenderContext = null;
    #elseif lime_webgl
	public static var gl(default, null):WebGL2RenderContext = null;
    #elseif lime_opengles
	public static var gl(default, null):OpenGLES3RenderContext = null;
	#end

    // public static var gl(default, null):OpenGLRenderContext;
    // public static var gl(default, null):WebGL2RenderContext;
    // public static var gl(default, null):OpenGLES3RenderContext;
    
    
    // public static var gl:OpenGLRenderContext = null;

    var vao:GLVertexArrayObject = null;
    var vbo:GLBuffer = null;

    var coloredShader:ColoredShader = null;
    var imageShader:SurfaceShader = null;

    var isCreated = false;

    // var screen:LimeSurface = null;
    var backbuffer:LimeSurface = null;

    // public var painter:ShapePainter = null;
    // public var attributePainter:AttributePainter = null;

    public var screenPainter:ShapeStructure = null;
    public var backbufferPainter:ShapeStructure = null;

    public var transform:Matrix = null;
    
    public var mouseDevice = new LimeMouse();

    public var keyboardDevice = new Input();

    public function new(gl, displayWidth:Int, displayHeight:Int) {
        LimeBackend.gl = gl;
        
        var context = new LimeContext();
        LimeContext.active = context;


        #if lime_opengl
        trace("OpenGl");
        #elseif lime_webgl
        trace("WebGl");
        #elseif lime_opengles
        trace("OpenGlEs");
        #end

        screenPainter = new ShapeStructure(10000);
        backbufferPainter = new ShapeStructure(10000);
        // attributePainter = new AttributePainter(1000);
        context.structure = screenPainter;

        //
        // var w = 800;
        // var h = 600;
        // var ratio = w / h;
        // var w = 1080;
        // var h = 2220;
        // transform = Matrix.Orthogonal(0, w, h, 0, 0, 10);



        // screen = new LimeSurface(displayWidth, displayHeight, screenPainter);
        // screen = new LimeSurface(1920, 1080, screenPainter);
        // screen.viewport(0, 0, 600, 800);
    }
    
    public function getGl() {
        return gl;
    }

    override public function screenSurface(w:Int, h:Int):Surface {
        return new LimeSurface(w, h, screenPainter);
    }

    override public function surface(w:Int, h:Int):Surface {
        var fbo = gl.createFramebuffer();
        gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);

        var texture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, texture);
        #if lime_opengl
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, 0);
        #elseif lime_webgl
        // gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, null); // null?
        #elseif lime_opengles
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, 0);
        #end
        // @note todo flag
        // gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        // gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        // gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT);
        // gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        // gl.bindTexture(gl.TEXTURE_2D, 0);
        
        
        var rbo = gl.createRenderbuffer();
        gl.bindRenderbuffer(gl.RENDERBUFFER, rbo);
        gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH24_STENCIL8, w, h);
        gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, gl.RENDERBUFFER, rbo);
        
        gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);
        #if lime_opengl
        gl.bindRenderbuffer(gl.RENDERBUFFER, 0);
        #elseif lime_webgl
        gl.bindRenderbuffer(gl.RENDERBUFFER, null);
        #elseif lime_opengles
        gl.bindRenderbuffer(gl.RENDERBUFFER, 0);
        #end

        return new LimeSurface(w, h, backbufferPainter, fbo, rbo, texture);
    }

    override function loadSurface(path:String):Surface {
        // @todo вынести в макросы (и, возможно, сделать хранение байт внутри макросов с помощью метода store...)

        var image = crovown.ds.Assets.images.get(path);
        // var stream = sys.io.File.read(path);
        // var data = new format.png.Reader(stream).read();
        // var header = format.png.Tools.getHeader(data);
        // var bytes = format.png.Tools.extract32(data, null, true);
        // for (i in 0...Std.int(bytes.length / 4)) {
        //     var b = bytes.get(i * 4 + 0);
        //     var r = bytes.get(i * 4 + 2);
        //     bytes.set(i * 4 + 0, r); //
        //     bytes.set(i * 4 + 2, b);
        //     // bytes.set(i * 4 + 3, 0);
        // }

        // for (i in 0...Std.int(header.width * header.height)) {
        //     // var b = bytes.get(i * 4 + 0);
        //     // var r = bytes.get(i * 4 + 2);
        //     // bytes.set(i * 4 + 0, r); //
        //     // bytes.set(i * 4 + 2, b);
        //     // // bytes.set(i * 4 + 3, 0);

        //     // bytes.setFloat(i * 4 + 0, 1);

        //     // bytes.set(i * 4 + 0, 255);
        //     bytes.set(i * 4 + 0, bytes.get(i * 4) > 120 ? 255 : 0);
        //     bytes.set(i * 4 + 1, 255);
        //     bytes.set(i * 4 + 2, 255);
        //     bytes.set(i * 4 + 3, 0);
        //     // bytes.setFloat(i * 8 + 2, 1);
        //     // bytes.setFloat(i * 8 + 4, 1);
        //     // bytes.setFloat(i * 8 + 6, 1);
        // }

        var texture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, texture);
        #if lime_opengl
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.w, image.h, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);
        #elseif lime_webgl
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.w, image.h, 0, gl.RGBA, gl.UNSIGNED_BYTE, UInt8Array.fromBytes(image.data));
        #elseif lime_opengles
        // gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.w, image.h, 0, gl.RGBA, gl.UNSIGNED_BYTE, new UInt8Array(image.data, 0, 0)); // @todo проверить UInt8Array.fromBytes(image.data)
        // gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.w, image.h, 0, gl.RGBA, gl.UNSIGNED_BYTE, UInt8Array.fromBytes(image.data));
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.w, image.h, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);
        #end
        // gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, header.width, header.height, 0, gl.RGBA, gl.FLOAT, bytes);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        
        #if lime_opengl
        gl.bindTexture(gl.TEXTURE_2D, 0);
        #elseif lime_webgl
        gl.bindTexture(gl.TEXTURE_2D, null);
        #elseif lime_opengles
        gl.bindTexture(gl.TEXTURE_2D, 0);
        #end

        return new LimeSurface(image.w, image.h, backbufferPainter, null, null, texture);
    }

    // https://www.opengl-tutorial.org/intermediate-tutorials/tutorial-14-render-to-texture/
    // @todo передавать флаг - render texture или нет
    override public function loadImage(image:crovown.ds.Image):Surface {
        var fbo = gl.createFramebuffer();
        gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);

        var texture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, texture);
        #if lime_opengl
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.w, image.h, 0, gl.RGBA, gl.UNSIGNED_BYTE, UInt8Array.fromBytes(image.data));
        #elseif lime_webgl
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.w, image.h, 0, gl.RGBA, gl.UNSIGNED_BYTE, UInt8Array.fromBytes(image.data));
        #elseif lime_opengles
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.w, image.h, 0, gl.RGBA, gl.UNSIGNED_BYTE, UInt8Array.fromBytes(image.data));
        #end
        // @note todo
        // gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        // gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        // gl.bindTexture(gl.TEXTURE_2D, 0);
        
        
        var rbo = gl.createRenderbuffer();
        gl.bindRenderbuffer(gl.RENDERBUFFER, rbo);
        gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH24_STENCIL8, image.w, image.h);
        gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, gl.RENDERBUFFER, rbo);
        
        gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);
        #if lime_opengl
        gl.bindRenderbuffer(gl.RENDERBUFFER, 0);
        #elseif lime_webgl
        gl.bindRenderbuffer(gl.RENDERBUFFER, null);
        #elseif lime_opengles
        gl.bindRenderbuffer(gl.RENDERBUFFER, 0);
        #end

        return new LimeSurface(image.w, image.h, backbufferPainter, fbo, rbo, texture);
    }

    override public function shader<S:Shader>(label:String):S {
        return switch (label) {
            case ColoredShader.label: return cast new LimeColoredShader(screenPainter);
            case SurfaceShader.label: return cast new LimeSurfaceShader(screenPainter);
            case GradientShader.label: return cast new LimeGradientShader(screenPainter);
            case MixShader.label: return cast new LimeMixShader(screenPainter);
            case MaskShader.label: return cast new LimeMaskShader(screenPainter);
            case AdjustColorShader.label: return cast new LimeAdjustColorShader(screenPainter);
            case BlurDirectionalShader.label: return cast new LimeBlurDirectionalShader(screenPainter);
            case OutlineShader.label: return cast new LimeOutlineShader(screenPainter);
            case SdfShader.label: return cast new LimeSdfShader(screenPainter);
            default: null;
        }
    }

    override public function mouse(index:Int):Mouse {
        if (index != 0) return null;
        return mouseDevice;
    }

    override function input(id:Int):Input {
        if (id != 0) return null;
        return keyboardDevice;
    }
}

class LimeMouse extends Mouse {
    public function new() {}
}

// @todo generic
class Structure {
    public var vao:GLVertexArrayObject = null;
    public var vbo:GLBuffer = null;
    public var ibo:GLBuffer = null;

    #if lime_opengl
    // @note @todo для работы на hl включите это
    // @upd не уверен в комментарии выше
    // public var vertices:ArrayBuffer = null;
    public var vertices:Float32Array = null;
    public var indices:UInt32Array = null;
    // public var indices:UInt8Array = null;
    #elseif lime_webgl
    // public var vertices:Bytes = null;
    // public var indices:Bytes = null;
    public var vertices:Float32Array = null;
    public var indices:UInt32Array = null;
    #elseif lime_opengles
    // public var vertices:ArrayBuffer = null; // Float32Array
    // public var indices:ArrayBuffer = null;
    public var vertices:Float32Array = null;
    public var indices:UInt32Array = null;
    #end

    public var size:Int;
    public var structureLength = 0;
    public var attrCount = 0;
    public var vIndex = 0;
    public var iIndex = 0;

    public function new(size = 36) {
        this.size = size;
        vao = LimeBackend.gl.createVertexArray();
        vbo = LimeBackend.gl.createBuffer();
        ibo = LimeBackend.gl.createBuffer();

        #if lime_opengl
        // vertices = new ArrayBuffer(size);
        // indices = new ArrayBuffer(size);
        vertices = new Float32Array(size);
        indices = new UInt32Array(size);
        // indices = new UInt8Array(size);
        #elseif lime_webgl
        // vertices = Bytes.alloc(size);
        // indices = Bytes.alloc(size);;
        vertices = new Float32Array(size);
        indices = new UInt32Array(size);
        #elseif lime_opengles
        // vertices = new ArrayBuffer(size);
        // indices = new ArrayBuffer(size);
        vertices = new Float32Array(size);
        indices = new UInt32Array(size);
        #end
    }

    public function reserve(count:Int) {
        var size = count * attrCount;
        if (size > this.size) {
            trace("ERROR: Structure is too big");
        } else if ((count + iIndex) >= this.size || (count + vIndex) * attrCount >= this.size) {
            return false;
        }
        // } else if ((count + iIndex) * structureLength > this.size || (count + vIndex) * structureLength > this.size) {
        return true;
    }

    public function update(vCount:Int, iCount:Int) {
        vIndex += vCount;
        iIndex += iCount;
        return this;
    }

    public function clear() {
        vIndex = 0;
        iIndex = 0;
        return this;
    }

    public function isEmpty() {
        return iIndex == 0;
    }

    public inline function setIdx(i:Int, a:Int, b:Int, c:Int) {
        indices[(i + iIndex) * 3 + 0] = a + vIndex;
        indices[(i + iIndex) * 3 + 1] = b + vIndex;
        indices[(i + iIndex) * 3 + 2] = c + vIndex;
        return this;
    }

    public function build() {
        var gl = LimeBackend.gl;
        // /*
        gl.bindVertexArray(vao);
        // */

        gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
        #if lime_opengl
        gl.bufferData(gl.ARRAY_BUFFER, size * 4, vertices, gl.STATIC_DRAW);
        #elseif lime_webgl
        gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
        #elseif lime_opengles
        gl.bufferData(gl.ARRAY_BUFFER, size * 4, vertices, gl.STATIC_DRAW);
        #end

        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibo);
        #if lime_opengl
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, size * 4, indices, gl.STATIC_DRAW);
        #elseif lime_webgl
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
        #elseif lime_opengles
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, size * 4, indices, gl.STATIC_DRAW);
        #end
    }

    public function bind(program:GLProgram) {
        
    }
}

typedef Attribute = {
    label:String,
    type:Int,
    size:Int,
    count:Int,
    offset:Int
}

class AttributeStructure extends Structure {
    var attributes = new Array<Attribute>();
    var offset = 0;

    // @todo macro (using #define)
    public var template = "
{INPUTS}

{OUTPUTS}

uniform mat4 mvp;

void main() {
    gl_Position = mvp * vec4(aPos, 1);
{ASSIGNS}
}";

    override public function build() {
        super.build();
        var gl = LimeBackend.gl;
        
        structureLength = attributes.fold((i, r) -> i.size * i.count + r, 0);
        var total = 0;
        for (i in 0...attributes.length) {
            var attr = attributes[i];
            gl.vertexAttribPointer(i, attr.count, attr.type, false, attrCount * 4, total * 4);  // structureLength вместо attrount * 4
            gl.enableVertexAttribArray(i);
            // trace(i, attr.count, attr.type, attrCount * 4, total * 4, structureLength);
            // trace(i, attr.count, attrCount * 4, total * 4);
            total += attr.count;
        }

        #if lime_opengl
        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
        gl.bindVertexArray(0);
        #elseif lime_webgl
        gl.bindBuffer(gl.ARRAY_BUFFER, null);
        gl.bindVertexArray(null);
        #elseif lime_opengles
        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
        gl.bindVertexArray(0);
        #end

        // setupStructure();   // @todo удалить
    }

    override public function bind(program:GLProgram) {
        var gl = LimeBackend.gl;
        for (i in 0...attributes.length) {
            gl.bindAttribLocation(program, i, attributes[i].label);
        }
    }

    // public function setupStructure() {
    //     var gl = LimeBackend.gl;
    //     gl.bindVertexArray(vao);
    //     gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    //     // gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibo);
    //     structureLength = attributes.fold((i, r) -> i.size * i.count + r, 0);
    //     var total = 0;
    //     for (i in 0...attributes.length) {
    //         var attr = attributes[i];
    //         gl.vertexAttribPointer(i, attr.count, attr.type, false, attrCount * 4, total * 4);  // structureLength вместо attrount * 4
    //         gl.enableVertexAttribArray(i);
    //         // trace(i, attr.count, attr.type, attrCount * 4, total * 4, structureLength);
    //         // trace(i, attr.count, attrCount * 4, total * 4);
    //         total += attr.count;
    //     }
    //     #if lime_opengl
    //     gl.bindVertexArray(0);
    //     #elseif lime_webgl
    //     gl.bindVertexArray(null);
    //     #elseif lime_opengles
    //     gl.bindVertexArray(0);
    //     #end
    // }

    public function add(label:String, count = 1) {
        var size = 4;   // @todo move to constructor
        attributes.push({
            label: label,
            type: LimeBackend.gl.FLOAT,
            size: size,
            count: count,
            offset: offset
        });
        offset += count;
        attrCount += count;
        return attributes.length - 1;
    }

    // @todo перерасчёт размера структуры
    // public function remove(label:String) {
    //     attributes.remove(attributes.find(a -> a.label == label));
    //     return this;
    // }

    public function setFloat(id:Int, i:Int, v:Float) {
        vertices[((i + vIndex) * attrCount + attributes[id].offset)] = v;
        
        // vertices.setFloat((i + vIndex) * structureLength + attributes[id].offset, v);
        return this;
    }

    public function setFloat2(id:Int, i:Int, x:Float, y:Float) {
        var attr = attributes[id];

        vertices[((i + vIndex) * attrCount + attr.offset)] = x;
        vertices[((i + vIndex) * attrCount + attr.offset + 1)] = y;

        // trace((i + vIndex) * attrCount + attr.offset, i);
        // trace((i + vIndex) * attrCount + attr.offset + 1);

        // vertices.setFloat((i + vIndex) * structureLength + attr.offset, x);
        // vertices.setFloat((i + vIndex) * structureLength + attr.offset + attr.size, y);
        return this;
    }

    public function setFloat3(id:Int, i:Int, x:Float, y:Float, z:Float) {
        var attr = attributes[id];

        vertices[((i + vIndex) * attrCount + attr.offset)] = x;
        vertices[((i + vIndex) * attrCount + attr.offset + 1)] = y;
        vertices[((i + vIndex) * attrCount + attr.offset + 2)] = z;
        // trace((i + vIndex) * attrCount + attr.offset, i, x, y, z);
        // trace(i, vIndex, structureLength, attr.offset, attr.size, ((i + vIndex) * structureLength + attr.offset), ((i + vIndex) * structureLength + attr.offset + attr.size));

        // vertices.setFloat((i + vIndex) * structureLength + attr.offset, x);
        // vertices.setFloat((i + vIndex) * structureLength + attr.offset + attr.size, y);
        // vertices.setFloat((i + vIndex) * structureLength + attr.offset + attr.size * 2, z);
        return this;
    }

    public function setFloat4(id:Int, i:Int, x:Float, y:Float, z:Float, w:Float) {
        var attr = attributes[id];

        vertices[((i + vIndex) * attrCount + attr.offset)] = x;
        vertices[((i + vIndex) * attrCount + attr.offset + 1)] = y;
        vertices[((i + vIndex) * attrCount + attr.offset + 2)] = z;
        vertices[((i + vIndex) * attrCount + attr.offset + 3)] = w;
        // trace(i, vIndex, structureLength, attr.offset, attr.size, ((i + vIndex) * structureLength + attr.offset), ((i + vIndex) * structureLength + attr.offset + attr.size));

        // vertices.setFloat((i + vIndex) * structureLength + attr.offset, x);
        // vertices.setFloat((i + vIndex) * structureLength + attr.offset + attr.size, y);
        // vertices.setFloat((i + vIndex) * structureLength + attr.offset + attr.size * 2, z);
        // vertices.setFloat((i + vIndex) * structureLength + attr.offset + attr.size * 3, w);
        return this;
    }

    public function generateVertex() {
        // var fragment = template.replace("{INPUTS}", [for (attr in attributes) ("in " +
        //     if (attr.count == 2) "vec2"
        //     else if (attr.count == 3) "vec3"
        //     else if (attr.count == 4) "vec4"
        //     else "float") +
        //     ' a${attr.label.capitalize()};'
        // ].join("\n"));

        var fragment = template.replace("{INPUTS}", [for (i in 0...attributes.length) ('layout(location = ${i}) in ' +
            if (attributes[i].count == 2) "vec2"
            else if (attributes[i].count == 3) "vec3"
            else if (attributes[i].count == 4) "vec4"
            else "float") +
            ' a${attributes[i].label.capitalize()};'
        ].join("\n"));

        fragment = fragment.replace("{OUTPUTS}", [for (attr in attributes) ("out " +
            if (attr.count == 2) "vec2"
            else if (attr.count == 3) "vec3"
            else if (attr.count == 4) "vec4"
            else "float") +
            ' ${attr.label};'
        ].join("\n"));

        fragment = fragment.replace("{ASSIGNS}", [for (attr in attributes)
            attr.label + " = " + 'a${attr.label.capitalize()};'
        ].join("\n"));

        return fragment;
    }
}

class ShapeStructure extends AttributeStructure {
    public var bounds(default, null):Box = new Box();
    public var isBoundsDirty = true;

    public function new(size = 36) {
        super(size);
        add("pos", 3);
        add("col", 4);
        add("uv", 2);
        // setupStructure();
    }

    override function build() {
        isBoundsDirty = true;
        super.build();
    }

    public inline function setPos(i:Int, x:Float, y:Float, z:Float) {
        if (isBoundsDirty) {
            bounds.set(x, y, z);
            isBoundsDirty = false;
        } else {
            bounds.extend(x, y, z);
        }
        return setFloat3(0, i, x, y, z);
    }

    public inline function setCol(i:Int, r:Float, g:Float, b:Float, a:Float) {
        return setFloat4(1, i, r, g, b, a);
    }

    public inline function setUv(i:Int, u:Float, v:Float) {
        return setFloat2(2, i, u, v);
    }
}

class LimeSurface extends Surface {
    public var fbo:GLFramebuffer = null;
    public var rbo:GLRenderbuffer = null;
    public var texture:GLTexture = null;
    public var scissors = new Array<Rectangle>();

    var isDirty = false;
    var w:Int;
    var h:Int;
    // var width:Int;
    // var height:Int;
    var z = -0.1;
    var font:Font = null;
    var view = new Rectangle();

    // public var transform = Matrix.Identity();
    public var identity = Matrix.Identity();
    public var transformation = new Array<Matrix>();
    var support = new Float32Array(16);

    public var color = Vector.Ones();
    public var shader(default, set):Shader = null;
    function set_shader(v:Shader) {
        if (shader != null && v != shader) flush();
        return shader = v;
    }

    public var structure(default, set):ShapeStructure = null;
    function set_structure(v:ShapeStructure) {
        if (structure != null && v != structure) flush();
        return structure = v;
    }

    public function new(w:Int, h:Int, structure:ShapeStructure, ?fbo:GLFramebuffer, ?rbo:GLRenderbuffer, ?texture:GLTexture) {
        super(
            new LimeColoredShader(structure)
        );
        this.w = w;
        this.h = h;
        // width = w;
        // height = h;
        this.structure = structure;
        this.fbo = fbo;
        this.rbo = rbo;
        this.texture = texture;
        viewport(0, 0, w, h);
        // view.set(0, 0, 1, 1);
    }

    public function getLimeTransform():Matrix4 {
        var transform = getTransform();
        // trace(transform);
        support[0] = transform._00;
        support[1] = transform._01;
        support[2] = transform._02;
        support[3] = transform._03;
        support[4] = transform._10;
        support[5] = transform._11;
        support[6] = transform._12;
        support[7] = transform._13;
        support[8] = transform._20;
        support[9] = transform._21;
        support[10] = transform._22;
        support[11] = transform._23;
        support[12] = transform._30;
        support[13] = transform._31;
        support[14] = transform._32;
        support[15] = transform._33;
        return support;
    }

    public function lazyDraw(reserve:Int) {
        if (!structure.reserve(reserve)) flush();
        isDirty = true;
        return this;
    }
    
    // override public function flush(clear = true) {
    override public function flush() {
        // /*
        if (shader == null) return;
        if (!isDirty) return;
        var gl = LimeBackend.gl;
        gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
        // gl.viewport(0, 0, w, h);
        gl.viewport(Std.int(view.x * w), Std.int(view.y * h), Std.int(view.w * w), Std.int(view.h * h));
        structure.build();
        
        gl.enable(gl.BLEND);
        // gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
        // gl.blendEquation(gl.FUNC_ADD);

        // https://www.khronos.org/opengl/wiki/Blending
        gl.blendEquationSeparate(gl.FUNC_ADD, gl.FUNC_ADD);
        gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
        // gl.blendFuncSeparate(gl.ONE, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE);

        if (scissors.length > 0) {
            var scissor = scissors[scissors.length - 1];
            gl.enable(gl.SCISSOR_TEST);
            gl.scissor(Std.int(scissor.x), Std.int(view.h * h - scissor.y - scissor.h), Std.int(scissor.w), Std.int(scissor.h));
        }
        
        shader.apply(this);
        gl.bindVertexArray(structure.vao);
        // gl.drawElements(gl.TRIANGLES, structure.iIndex, gl.UNSIGNED_INT, 0);
        gl.drawElements(gl.TRIANGLES, structure.iIndex * 3, gl.UNSIGNED_INT, 0);
        // trace(structure.iIndex, structure.vIndex);
        // gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, structure.ibo);
        // gl.drawElements(gl.TRIANGLES, structure.iIndex * 3, gl.UNSIGNED_BYTE, 0);
        // gl.bindFramebuffer(gl.FRAMEBUFFER, null);   // @todo удалить или проверить UPD вроде работает
        if (true) structure.clear();
        if (scissors.length > 0) gl.disable(gl.SCISSOR_TEST);
        isDirty = false;
        // */

        // structure.build();
        // if (true) structure.clear();
    }

    // override public function getActualWidth() {
    //     return w;
    // }

    // override public function getActualHeight() {
    //     return h;
    // }

    override function save():Bytes {
        var gl = LimeBackend.gl;
        gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
        // gl.activeTexture(gl.TEXTURE0);
        // gl.readBuffer(gl.COLOR_ATTACHMENT0);
        gl.bindTexture(gl.TEXTURE_2D, texture);
        var data = new UInt8Array(w * h * 4);
        gl.readPixels(0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, data);
        var bytes = data.toBytes();
        for (i in 0...Std.int(bytes.length / 4)) {
            var b = bytes.get(i * 4 + 0);
            var r = bytes.get(i * 4 + 2);
            bytes.set(i * 4 + 0, r);
            bytes.set(i * 4 + 2, b);
        }

        // Flip vertical
        // 4 - size of single RGBA pixel (1 byte per channel)
        var itemsInRow = w * 4;
        for (i in 0...Std.int(bytes.length / 4 / 2)) {
            var row = Std.int(i / w);
            var inverse = h - row - 1;
            var pos = (inverse * w + i % w) * 4;
            
            var a = bytes.getInt32(i * 4);
            var b = bytes.getInt32(pos);
            bytes.setInt32(i * 4, b);
            bytes.setInt32(pos, a);
        }



        #if lime_opengl
        gl.bindTexture(gl.TEXTURE_2D, 0);
        #elseif lime_webgl
        gl.bindTexture(gl.TEXTURE_2D, null);
        #elseif lime_opengles
        gl.bindTexture(gl.TEXTURE_2D, 0);
        #end

        return bytes;
    }

    override public function getWidth() {
        return w;
    }

    override public function getHeight() {
        return h;
    }

    // override function resize(w:Int, h:Int) {
    //     width = w;
    //     height = h;
    // }

    override public function viewport(x:Int, y:Int, w:Int, h:Int) {
        // var scaleX = width / this.w;
        // var scaleY = height / this.h;
        var scaleX = w / this.w;
        var scaleY = h / this.h;
        view.set(
            x * scaleX, y * scaleY,
            scaleX, scaleY
        );
        // gl.viewport(x, y, w, h);
    }

    override public function setDepth(z:Float) {
        // @todo push transform
        this.z = z;
    }

    override public function getDepth() {
        return z;
    }

    override function setColor(?color:Color) {
        if (color == null) {
            this.color.ones();
            return;
        }
        this.color = crovown.types.Color.fromARGB(color);
    }
    
    override public function setShader(shader:Shader) {
        this.shader = cast shader;
    }

    override function setFont(font:Font) {
        this.font = font;
    }

    // override public function setTransform(transform:Matrix) {
    //     this.transform = transform;
    // }

    override public function getTransform():Matrix {
        // trace("--------", transformation);
        return transformation.length > 0 ? transformation[transformation.length - 1] : identity;
        // return transform;
    }

    override public function clearTransform() {
        if (transformation.length > 0) flush();
        transformation.resize(0);
    }

    override public function pushTransform(transform:Matrix) {
        if (transformation.length > 0) flush();
        // @todo использовать пул трансформаций вместо того, чтобы каждый раз создавать новую трансформацию
        transformation.push(getTransform().MultMat(transform));
        // transformation.push(transform.MultMat(getTransform()));
    }

    override public function popTransform() {
        if (transformation.length > 0) flush();
        transformation.pop();
    }

    override public function pushScissors(x:Int, y:Int, w:Int, h:Int) {
        scissors.push(new Rectangle(x, y, w, h));
    }

    override public function popScissors() {
        scissors.pop();
    }

    override public function clearScissors() {
        scissors.resize(0);
    }

    override public function clear(color:Color) {
        var gl = LimeBackend.gl;
        var v = crovown.types.Color.fromARGB(color);
        gl.clearColor(v.x, v.y, v.z, v.w);
        // gl.clear(gl.COLOR_BUFFER_BIT);
        gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
        gl.bindFramebuffer(gl.FRAMEBUFFER, null);   // @todo 0/null в зависимости от target
    }

    override public function fill() {
        drawRect(0, 0, w, h);
    }

    override public function drawPixel(x:Float, y:Float) {
        drawRect(x, y, 1, 1);
    }

    override public function drawTri(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float) {
        lazyDraw(3);
        
        structure.setPos(0, x1, y1, z);
        structure.setPos(1, x2, y2, z);
        structure.setPos(2, x3, y3, z);

        structure.setCol(0, color.x, color.y, color.z, color.w);
        structure.setCol(1, color.x, color.y, color.z, color.w);
        structure.setCol(2, color.x, color.y, color.z, color.w);

        structure.setUv(0, 0, 0);
        structure.setUv(1, 1, 0);
        structure.setUv(2, 1, 1);
        
        structure.setIdx(0, 0, 1, 2);

        structure.update(3, 1);
    }

    override function drawRect(x:Float, y:Float, w:Float, h:Float) {
        lazyDraw(4);

        var z = 0;  //
        // var z = -0.01;
        // pushTransform(Matrix.Translation(0, 0, -0.1));
        structure.setPos(0, x, y, z);
        structure.setPos(1, x + w, y, z);
        structure.setPos(2, x + w, y + h, z);
        structure.setPos(3, x, y + h, z);
        // trace(structure.bounds, x, y, w, h, structure.vao);

        structure.setCol(0, color.x, color.y, color.z, color.w);
        structure.setCol(1, color.x, color.y, color.z, color.w);
        structure.setCol(2, color.x, color.y, color.z, color.w);
        structure.setCol(3, color.x, color.y, color.z, color.w);

        // structure.setUv(0, 0, 0);
        // structure.setUv(1, 1, 0);
        // structure.setUv(2, 1, 1);
        // structure.setUv(3, 0, 1);
        //
        structure.setUv(0, 0, 1);
        structure.setUv(1, 1, 1);
        structure.setUv(2, 1, 0);
        structure.setUv(3, 0, 0);

        // trace(view.w, view.h);
        // structure.setUv(0, view.x, view.y + view.h);
        // structure.setUv(1, view.x + view.w, view.y + view.h);
        // structure.setUv(2, view.x + view.w, view.y);
        // structure.setUv(3, view.x, view.y);

        structure.setIdx(0, 0, 1, 2);
        structure.setIdx(1, 0, 2, 3);

        structure.update(4, 2);
    }

    override public function drawSubRect(x:Float, y:Float, w:Float, h:Float) {
        lazyDraw(4);

        var z = 0;  //
        // var z = -0.01;
        // pushTransform(Matrix.Translation(0, 0, -0.1));
        structure.setPos(0, x, y, z);
        structure.setPos(1, x + w, y, z);
        structure.setPos(2, x + w, y + h, z);
        structure.setPos(3, x, y + h, z);

        structure.setCol(0, color.x, color.y, color.z, color.w);
        structure.setCol(1, color.x, color.y, color.z, color.w);
        structure.setCol(2, color.x, color.y, color.z, color.w);
        structure.setCol(3, color.x, color.y, color.z, color.w);

        structure.setUv(0, view.x, view.y + view.h);
        structure.setUv(1, view.x + view.w, view.y + view.h);
        structure.setUv(2, view.x + view.w, view.y);
        structure.setUv(3, view.x, view.y);

        structure.setIdx(0, 0, 1, 2);
        structure.setIdx(1, 0, 2, 3);

        structure.update(4, 2);
    }

    override public function drawTile(x:Float, y:Float, w:Float, h:Float, dx:Float, dy:Float, dw:Float, dh:Float) {
        lazyDraw(4);

        var z = 0;
        structure.setPos(0, x, y, z);
        structure.setPos(1, x + w, y, z);
        structure.setPos(2, x + w, y + h, z);
        structure.setPos(3, x, y + h, z);

        structure.setCol(0, color.x, color.y, color.z, color.w);
        structure.setCol(1, color.x, color.y, color.z, color.w);
        structure.setCol(2, color.x, color.y, color.z, color.w);
        structure.setCol(3, color.x, color.y, color.z, color.w);

        structure.setUv(0, dx, dy + dh);
        structure.setUv(1, dx + dw, dy + dh);
        structure.setUv(2, dx + dw, dy);
        structure.setUv(3, dx, dy);

        structure.setIdx(0, 0, 1, 2);
        structure.setIdx(1, 0, 2, 3);

        structure.update(4, 2);
    }

    override public function drawLine(x1:Float, y1:Float, x2:Float, y2:Float, thickness:Float) {
        lazyDraw(4);

        var x = x2 - x1;
        var y = y2 - y1;
        var length = Math.sqrt(x * x + y * y);
        var dx = x / length * thickness / 2;
        var dy = y / length * thickness / 2;

        structure.setPos(0, x1 + -dy, y1 + dx, z);
        structure.setPos(1, x1 + dy, y1 + -dx, z);
        structure.setPos(2, x2 + dy, y2 + -dx, z);
        structure.setPos(3, x2 + -dy, y2 + dx, z);

        structure.setCol(0, color.x, color.y, color.z, color.w);
        structure.setCol(1, color.x, color.y, color.z, color.w);
        structure.setCol(2, color.x, color.y, color.z, color.w);
        structure.setCol(3, color.x, color.y, color.z, color.w);

        structure.setUv(0, 0, 0);
        structure.setUv(1, 1, 0);
        structure.setUv(2, 1, 1);
        structure.setUv(3, 0, 1);

        structure.setIdx(0, 0, 1, 2);
        structure.setIdx(1, 0, 2, 3);

        structure.update(4, 2);
    }

    override function drawString(string:String, x:Float, y:Float) {
        var x = x;
        var y = y;
        var z = 0;  //
        // trace(x, y, string);
        for (i in 0...string.length) {
            var char = string.charAt(i);
            var data = font.chars.get(char);
            if (data == null || char == " ") {
                x += font.wordSpacing * font.scale;
                continue;
            }
            lazyDraw(4);
            var y = y + MathUtils.lerp(font.align, -1, 0, 1, data.dy * font.scale);
            var xx = x + data.dx * font.scale;
            x = xx; // @todo
            structure.setPos(0, xx, y, z);
            structure.setPos(1, xx + data.w * font.scale, y, z);
            structure.setPos(2, xx + data.w * font.scale, y + data.h * font.scale, z);
            structure.setPos(3, xx, y + data.h * font.scale, z);
    
            structure.setCol(0, color.x, color.y, color.z, color.w);
            structure.setCol(1, color.x, color.y, color.z, color.w);
            structure.setCol(2, color.x, color.y, color.z, color.w);
            structure.setCol(3, color.x, color.y, color.z, color.w);
    
            var texW = data.w / font.w;
            var texH = data.h / font.h;
            var texX = data.x / font.w;
            var texY = (1 - data.y / font.h) + (font.h - texH);
            structure.setUv(0, texX, texY + texH);
            structure.setUv(1, texX + texW, texY + texH);
            structure.setUv(2, texX + texW, texY);
            structure.setUv(3, texX, texY);
    
            structure.setIdx(0, 0, 1, 2);
            structure.setIdx(1, 0, 2, 3);
            structure.update(4, 2);
            x += data.w * font.scale + font.letterSpacing[0] * font.scale;
        }
    }

    override public function drawConvexPolygon(points:Array<Float>) {
        flush();
        var count = Std.int(points.length / 3);
        
        for (i in 0...count) {
            structure.setPos(i, points[i * 3], points[i * 3 + 1], points[i * 3 + 2]);
            structure.setCol(i, color.x, color.y, color.z, color.w);
        }
        
        for (i in 0...count) {
            // Screen projection
            // @todo change algorithm and change flush to lazyDraw
            structure.setUv(i,
                (points[i * 3] - structure.bounds.x) / structure.bounds.w,
                1 - (points[i * 3 + 1] - structure.bounds.y) / structure.bounds.h
            );
        }
        
        for (i in 0...count - 2) {
            structure.setIdx(i, 0, i + 1, i + 2);
        }
        
        structure.update(count, count - 2);
        isDirty = true;
        flush();
    }

    public function useProgram(program:GLProgram) {
        LimeBackend.gl.useProgram(program);
    }
}

class LimeShader {
    public static function createProgram(vertex:String, fragment:String) {
        var gl = LimeBackend.gl;

        var defines = [
            #if lime_opengl
            "#version 330 core",
            
            #elseif lime_webgl
            "#version 300 es",
            "precision mediump float;",
            
            #elseif lime_opengles
            "#version 300 es",
            "precision mediump float;",
            #end
        ];
        var block = defines.join("\n") + "\n";

        var vertexShader = gl.createShader(gl.VERTEX_SHADER);
        gl.shaderSource(vertexShader, block + vertex);
        gl.compileShader(vertexShader);
        var log = gl.getShaderInfoLog(vertexShader);
        if (log != null && log.length > 0) {
            trace("==========================================");
            trace(log);
            trace(vertex);
        }

        var fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(fragmentShader, block + fragment);
        gl.compileShader(fragmentShader);
        var log = gl.getShaderInfoLog(fragmentShader);
        if (log != null && log.length > 0) {
            trace("==========================================");
            trace(log);
            trace(fragment);
        }
    
        var program = gl.createProgram();
        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        gl.linkProgram(program);
        // trace("==========================================", gl.getProgramInfoLog(program));
    
        gl.deleteShader(vertexShader);
        gl.deleteShader(fragmentShader);
        
        return program;
    }

    public static function setInt(program:GLProgram, label:String, v:Int) {
        LimeBackend.gl.uniform1i(LimeBackend.gl.getUniformLocation(program, label), v);
    }

    public static function setFloat(program:GLProgram, label:String, v:Float) {
        LimeBackend.gl.uniform1f(LimeBackend.gl.getUniformLocation(program, label), v);
    }

    public static function setFloat4(program:GLProgram, label:String, a:Float, b:Float, c:Float, d:Float) {
        LimeBackend.gl.uniform4f(LimeBackend.gl.getUniformLocation(program, label), a, b, c, d);
    }

    public static function setFloat2(program:GLProgram, label:String, a:Float, b:Float) {
        LimeBackend.gl.uniform2f(LimeBackend.gl.getUniformLocation(program, label), a, b);
    }

    public static function setMatrix4(program:GLProgram, label:String, v:Matrix4) {
        #if lime_opengl
        LimeBackend.gl.uniformMatrix4fv(LimeBackend.gl.getUniformLocation(program, label), 1, false, v);
        #elseif lime_webgl
        LimeBackend.gl.uniformMatrix4fv(LimeBackend.gl.getUniformLocation(program, label), false, v);
        #elseif lime_opengles
        LimeBackend.gl.uniformMatrix4fv(LimeBackend.gl.getUniformLocation(program, label), 1, false, v);
        #end
        // LimeBackend.gl.uniformMatrix4fv(LimeBackend.gl.getUniformLocation(program, label), 1, false, v);
    }

    public static function setFloats(program:GLProgram, label:String, v:Float32Array) {
        #if lime_opengl
        LimeBackend.gl.uniform1fv(LimeBackend.gl.getUniformLocation(program, label), v.length, v);
        #elseif lime_webgl
        LimeBackend.gl.uniform1fv(LimeBackend.gl.getUniformLocation(program, label), v);
        #elseif lime_opengles
        LimeBackend.gl.uniform1fv(LimeBackend.gl.getUniformLocation(program, label), v.length, v);
        #end
    }

    public static function setFloats4(program:GLProgram, label:String, v:Float32Array) {
        #if lime_opengl
        LimeBackend.gl.uniform4fv(LimeBackend.gl.getUniformLocation(program, label), Std.int(v.length / 4), v);
        #elseif lime_webgl
        LimeBackend.gl.uniform4fv(LimeBackend.gl.getUniformLocation(program, label), v);
        #elseif lime_opengles
        LimeBackend.gl.uniform4fv(LimeBackend.gl.getUniformLocation(program, label), Std.int(v.length / 4), v);
        #end
    }

    public static function setTexture(program:GLProgram, label:String, i:Int, v:GLTexture) {
        var gl = LimeBackend.gl;
        gl.activeTexture(gl.TEXTURE0 + i);
        gl.bindTexture(gl.TEXTURE_2D, v);
        gl.uniform1i(gl.getUniformLocation(program, label), i);
    }
}

class LimeColoredShader extends ColoredShader {
    public var program(default, null):GLProgram = null;
    var color = new Vector(1, 1, 1, 1);

    public function new(structure:AttributeStructure) {
        program = LimeShader.createProgram(structure.generateVertex(), "
            in vec3 pos;
            in vec4 col;
            in vec2 uv;

            uniform vec4 color;

            out vec4 frag;
            
            void main() {
                // frag = col;
                // frag = vec4(uv.x, uv.y, 1, 1);
                frag = color * col;  // @todo
                // frag = color;
                // frag = cc;
                // frag = vec4(1);
            }
        ");
        structure.bind(program);
    }

    override public function apply(surface:Surface) {
        var gl = LimeBackend.gl;
        gl.useProgram(program);
        var surface = cast(surface, LimeSurface);
        // var mvpID = gl.getUniformLocation(program, "mvp");
        // gl.uniformMatrix4fv(mvpID, 1, false, surface.getLimeTransform());
        LimeShader.setMatrix4(program, "mvp", surface.getLimeTransform());
        LimeShader.setFloat4(program, "color", color.x, color.y, color.z, color.w);
    }

    override public function setColor(color:Color) {
        this.color = crovown.types.Color.fromARGB(color);
    }
}

class LimeSurfaceShader extends SurfaceShader {
    public var program(default, null):GLProgram = null;
    // var imageID(default, null):GLUniformLocation = 0;
    var image:LimeSurface = null;
    var tile = new Vector(0, 0, 1, 1);  // @todo Rectangle

    public function new(structure:AttributeStructure) {
        program = LimeShader.createProgram(structure.generateVertex(), "
            in vec3 pos;
            in vec4 col;
            in vec2 uv;

            uniform sampler2D image;
            uniform vec4 tile;

            out vec4 frag;

            void main() {
                // frag = col;
                // frag = vec4(uv.x, uv.y, 1, 1);
                // frag = texture(image, vec2(uv.x, 1-uv.y));
                // frag = texture(image, uv);   //
                // frag = texture(image, uv) + vec4(uv.x, uv.y, 1, 1);
                frag = texture(image, vec2(uv.x * tile.z + tile.x, uv.y * tile.w + tile.y)) * col;   // @todo
                // frag = vec4(1);
                // frag = vec4(1, 1, 1, 0.5);
            }
        ");

        structure.bind(program);
    }

    override public function apply(surface:Surface) {
        var gl = LimeBackend.gl;
        gl.useProgram(program);
        var surface = cast(surface, LimeSurface);
        LimeShader.setMatrix4(program, "mvp", surface.getLimeTransform());
        LimeShader.setTexture(program, "image", 0, image.texture);
        LimeShader.setFloat4(program, "tile", tile.x, tile.y, tile.z, tile.w);
    }

    override public function setSurface(surface:Surface) {
        image = cast surface;
    }

    override public function setTile(x:Float, y:Float, w:Float, h:Float) {
        tile.set(x * w, 1 - y * h - h, w, h);
    }
}

class LimeGradientShader extends GradientShader {
    public var program(default, null):GLProgram = null;
    var start = new Vector();
    var end = new Vector();
    var count = 0;
    var stops = new Float32Array(GradientShader.buffer);
    var colors = new Float32Array(GradientShader.buffer * 4);
    
    public function new(structure:AttributeStructure) {
        program = LimeShader.createProgram(structure.generateVertex(), "
            in vec3 pos;
            in vec4 col;
            in vec2 uv;

            uniform vec2 start;
            uniform vec2 end;
            uniform int count;
            uniform float stops[16];
            uniform vec4 colors[16];

            out vec4 frag;

            void main() {
                vec2 dir = end - start;
                // @todo make a condition
                // float grad = dot(pos.xy - start, dir) / dot(dir, dir);
                float grad = dot(vec2(uv.x, 1.0 - uv.y) - start, dir) / dot(dir, dir);

                vec4 col = colors[0];
                for (int i = 1; i < count; ++i) {
                    col = mix(col, colors[i], clamp((grad - stops[i - 1]) / (stops[i] - stops[i - 1]), 0.0, 1.0));
                }

                frag = col;
            }
        ");
        structure.bind(program);
    }

    override public function apply(surface:Surface) {
        var surface = cast(surface, LimeSurface);
        surface.useProgram(program);
        LimeShader.setMatrix4(program, "mvp", surface.getLimeTransform());
        LimeShader.setFloat2(program, "start", start.x, start.y);
        LimeShader.setFloat2(program, "end", end.x, end.y);
        LimeShader.setInt(program, "count", count);
        LimeShader.setFloats(program, "stops", stops);
        LimeShader.setFloats4(program, "colors", colors);
    }

    override public function setPoints(points:Array<GradientPoint>) {
        count = points.length;
        for (i in 0...points.length) {
            var point = points[i];
            stops[i] = point.stop;
            colors[i * 4 + 0] = (point.color >> 16 & 0xFF) / 255.0;
            colors[i * 4 + 1] = (point.color >> 8  & 0xFF) / 255.0;
            colors[i * 4 + 2] = (point.color       & 0xFF) / 255.0;
            colors[i * 4 + 3] = (point.color >> 24 & 0xFF) / 255.0;
        }
    }
    
    override public function setStart(x:Float, y:Float, z = 0.0) {
        start.set(x, y, z);
    }
    
    override public function setEnd(x:Float, y:Float, z = 0.0) {
        end.set(x, y, z);
    }
}

class LimeMixShader extends MixShader {
    public var program(default, null):GLProgram = null;

    var src:LimeSurface = null;
    var dst:LimeSurface = null;
    var blend:Blend = AlphaOver;
    var factor = 1.0;
    var alpha = false;

    public function new(structure:AttributeStructure) {
        program = LimeShader.createProgram(structure.generateVertex(), "
            const int Normal        = 0;
            const int AlphaOver     = 1;
            const int Dissolve      = 5;
            const int Add           = 10;
            const int Subtract      = 15;
            const int Multiply      = 20;
            const int Divide        = 25;
            const int Screen        = 30;
            const int Exclusion     = 35;
            const int Difference    = 40;
            const int Power         = 45;
            const int Root          = 50;
            const int Overlay       = 55;
            const int HardLight     = 60;
            const int SoftLight     = 65;
            const int VividLight    = 70;
            const int LinearLight   = 75;
            const int Lighten       = 80;
            const int Darken        = 85;
            const int ColorBurn     = 90;
            const int LinearBurn    = 95;
            const int ColorDodge    = 100;
            const int LinearDodge   = 105;
            const int Hue           = 110;
            const int Saturation    = 115;
            const int Value         = 120;
            const int Color         = 125;
            // const int Offset        = 130;
            // const int Rotation      = 135;
            
            in vec3 pos;
            in vec4 col;
            in vec2 uv;

            uniform sampler2D src;
            uniform sampler2D dst;
            uniform int blend;
            uniform float factor;
            uniform int alpha;

            out vec4 frag;

            void main() {
                vec4 s = texture(src, uv);
                vec4 d = texture(dst, uv);
                float a = (alpha == 1) ? 1.0 : s.a;
                // float a = (alpha == 1) ? 1.0 : d.a;

                vec4 m = vec4(0);
                // // m = mix(s, d, d.w);
                // m = d;
                // if (true) {

                // }
                if (blend == Normal) {
                    m = d;
                } else if (blend == AlphaOver) {
                    // https://apoorvaj.io/alpha-compositing-opengl-blending-and-premultiplied-alpha/
                    // float finalAlpha = d.a + s.a * (1.0 - d.a);
                    // m = vec4((d.rgb * d.a + s.rgb * s.a * (1.0 - d.a)) / finalAlpha, finalAlpha);
                    
                    // float finalAlpha = d.a + s.a * (1.0 - d.a);
                    // m = vec4((d.rgb + s.rgb) / finalAlpha, finalAlpha);
                    // m = vec4((d.rgb * d.a + s.rgb * s.a * (1.0 - d.a)) / finalAlpha, 1);
                    
                    // m = mix(s, )

                    // https://github.com/blender/blender/blob/fc8341538a9cd5e0e4c049497277507b82237c9a/source/blender/compositor/realtime_compositor/shaders/library/gpu_shader_compositor_alpha_over.glsl#L23
                    // m = mix(s, vec4(d.rgb, 1.0), d.a);
                    m = (1.0 - d.a) * s + d;
                } else if (blend == Dissolve) {
        
                } else if (blend == Add) {
                    m = s + d;
                    m.a = a;
                } else if (blend == Subtract) {
                    m = s - d;
                    m.a = a;
                } else if (blend == Multiply) {
                    m = s * d;
                    m.a = a;
                } else if (blend == Divide) {
                    m = s / d;
                    m.a = a;
                } else if (blend == Screen) {
                    
                } else if (blend == Exclusion) {
                    
                } else if (blend == Difference) {
                    
                } else if (blend == Power) {
                    
                } else if (blend == Root) {
                    
                } else if (blend == Overlay) {
                    
                } else if (blend == HardLight) {
                    
                } else if (blend == SoftLight) {
                    
                } else if (blend == VividLight) {
                    
                } else if (blend == LinearLight) {
                    
                } else if (blend == Lighten) {
                    
                } else if (blend == Darken) {
                    
                } else if (blend == ColorBurn) {
                    
                } else if (blend == LinearBurn) {
                    
                } else if (blend == ColorDodge) {
                    
                } else if (blend == LinearDodge) {
                    
                } else if (blend == Hue) {
                    
                } else if (blend == Saturation) {
                    
                } else if (blend == Value) {
                    
                } else if (blend == Color) {
                    
                }
                frag = mix(s, m, factor);
            }
        ");
        structure.bind(program);
    }

    override public function apply(surface:Surface) {
        var surface = cast(surface, LimeSurface);
        surface.useProgram(program);
        LimeShader.setMatrix4(program, "mvp", surface.getLimeTransform());
        LimeShader.setTexture(program, "src", 0, src.texture);
        LimeShader.setTexture(program, "dst", 1, dst.texture);
        LimeShader.setInt(program, "blend", blend);
        LimeShader.setFloat(program, "factor", factor);
        LimeShader.setInt(program, "alpha", alpha ? 1 : 0);
    }

    override public function setSource(surface:Surface) {
        src = cast surface;
    }
    
    override public function setDestination(surface:Surface) {
        dst = cast surface;
    }
    
    override public function setBlend(blend:Blend) {
        this.blend = blend;
    }

    override public function setFactor(f:Float) {
        factor = f;
    }

    override function setAlpha(a:Bool) {
        alpha = a;
    }
}

class LimeMaskShader extends MaskShader {
    public var program(default, null):GLProgram = null;
    var image:LimeSurface = null;
    var mask:LimeSurface = null;
    var threshold = 0.01;

    public function new(structure:AttributeStructure) {
        program = LimeShader.createProgram(structure.generateVertex(), "
            in vec3 pos;
            in vec4 col;
            in vec2 uv;

            uniform sampler2D image;
            uniform sampler2D mask;
            uniform float threshold;

            out vec4 frag;
            
            void main() {
                vec4 c = texture(image, uv);
                vec4 m = texture(mask, uv);
                // frag = vec4(c.x, c.y, c.z, c.w * m.x);
                frag = m.r > threshold ? c : vec4(0.0, 0.0, 0.0, 0.0);
            }
        ");
        structure.bind(program);
    }

    override public function apply(surface:Surface) {
        var surface = cast(surface, LimeSurface);
        surface.useProgram(program);
        LimeShader.setMatrix4(program, "mvp", surface.getLimeTransform());
        LimeShader.setTexture(program, "image", 0, image.texture);
        LimeShader.setTexture(program, "mask", 1, mask.texture);
        LimeShader.setFloat(program, "threshold", threshold);
    }

    override function setSurface(s:Surface) {
        image = cast s;
    }

    override function setMask(m:Surface) {
        mask = cast m;
    }

    override function setThreshold(t:Float) {
        threshold = t;
    }

}

class LimeAdjustColorShader extends AdjustColorShader {
    public var program(default, null):GLProgram = null;
    var image:LimeSurface = null;

    public function new(structure:AttributeStructure) {
        program = LimeShader.createProgram(structure.generateVertex(), "
            in vec3 pos;
            in vec4 col;
            in vec2 uv;

            uniform sampler2D image;

            out vec4 frag;

            void main() {
                vec4 s = texture(image, uv);
                float c = (s.x + s.y + s.z) / 3.0;
                frag = vec4(c, c, c, s.a);
            }
        ");
        structure.bind(program);
    }

    override public function apply(surface:Surface) {
        var surface = cast(surface, LimeSurface);
        surface.useProgram(program);
        LimeShader.setMatrix4(program, "mvp", surface.getLimeTransform());
        LimeShader.setTexture(program, "image", 0, image.texture);
    }

    override public function setSurface(surface:Surface) {
        image = cast surface;
    }
}

class LimeBlurDirectionalShader extends BlurDirectionalShader {
    public var program(default, null):GLProgram = null;
    var image:LimeSurface = null;
    var color = Vector.Ones();
    var clip = false;
    var samples = 25;
    var direction = new Vector(1, 0);
    var radius = 10.0;

    public function new(structure:AttributeStructure) {
        program = LimeShader.createProgram(structure.generateVertex(), "
            in vec3 pos;
            in vec4 col;
            in vec2 uv;

            uniform sampler2D image;
            uniform int clip;
            uniform vec4 color;
            uniform int samples;
            uniform vec2 direction;
            uniform float radius;

            out vec4 frag;

            // float gaussian(float x, float sigma) {
            //     return exp(-(x * x) / (2.0 * sigma * sigma)) / (sqrt(2.0 * 3.141592654) * sigma);
            // }

            float gaussian(float x, float sigma) {
                return exp(-(x * x) / (2.0 * sigma * sigma));
            }

            void main() {
                float r = float(radius);
                // https://stackoverflow.com/questions/3149279/optimal-sigma-for-gaussian-filtering-of-an-image
                float sigma = (r * 2.0 - 1.0) / 6.0;
                float accum = 0.0;
                vec4 v = vec4(0.0, 0.0, 0.0, 0.0);
                for (int s = -samples; s < samples + 1; ++s) {
                    float x = float(s) / float(samples) * r;
                    float gauss = gaussian(x, sigma);
                    // @todo random offset to improve quality when samples count are low
                    v += texture(image, uv + direction * (x / 2.0 / 100.0)) * gauss;
                    accum += gauss;
                }

                if (clip == 1) {
                    frag = vec4(v.rgb / v.a, texture(image, uv).a * v.a / accum) * color;
                } else {
                    frag = vec4(v.rgb / v.a, v.a / accum) * color;
                }
            }
        ");
        structure.bind(program);
    }

    override public function apply(surface:Surface) {
        var surface = cast(surface, LimeSurface);
        surface.useProgram(program);
        LimeShader.setMatrix4(program, "mvp", surface.getLimeTransform());
        LimeShader.setTexture(program, "image", 0, image.texture);
        LimeShader.setFloat4(program, "color", color.x, color.y, color.z, color.w);
        LimeShader.setInt(program, "clip", clip ? 1 : 0);
        LimeShader.setInt(program, "samples", samples);
        LimeShader.setFloat2(program, "direction", direction.x, direction.y);
        LimeShader.setFloat(program, "radius", radius);
    }

    override function setSurface(surface:Surface) {
        image = cast surface;
    }

    override function setColor(c:Color) {
        color.load(crovown.types.Color.fromARGB(c));
    }
    
    override function setClip(c:Bool) {
        clip = c;
    }

    override function setSamples(s:Int) {
        samples = s;
    }
    
    override function setDirection(dx:Float, dy:Float) {
        direction.set(dx, dy);
    }
    
    override function setRadius(r:Float) {
        radius = r;
    }
}

class LimeOutlineShader extends OutlineShader {
    public var program(default, null):GLProgram = null;
    var bounds = new Rectangle();
    var image:LimeSurface = null;
    var color = new Vector(1, 1, 1, 1);
    var thickness = 10;
    var offset = new Vector();

    public function new(structure:AttributeStructure) {
        program = LimeShader.createProgram(structure.generateVertex(), "
            in vec3 pos;
            in vec4 col;
            in vec2 uv;

            uniform sampler2D image;
            uniform vec4 color;
            uniform int radius;
            uniform vec2 offset;
            uniform vec2 bounds;

            out vec4 frag;

            void main() {
                frag = vec4(0);
                vec2 o = vec2(-offset.x / bounds.x, offset.y / bounds.y);
                vec4 s = texture(image, uv);
                if (s.w > 0.0) {
                    frag = s;
                    return;
                }
                int diam = radius * 2;
                for (int i = 0; i < diam * diam; ++i) {
                    float dx = float(i / diam - radius) / bounds.x;
                    float dy = float(i % diam - radius) / bounds.y;
                    if (texture(image, uv + vec2(dx, dy) + o).w > 0.0) {
                        frag = mix(color, s, max(texture(image, uv + o).w, s.w));
                        break;
                    }
                }
            }
        ");
        structure.bind(program);
    }

    override public function getBounds():Rectangle {
        return bounds.set(
            offset.x - thickness, offset.y - thickness, thickness * 2, thickness * 2
        );
    }

    override public function apply(surface:Surface) {
        var surface = cast(surface, LimeSurface);
        surface.useProgram(program);
        LimeShader.setMatrix4(program, "mvp", surface.getLimeTransform());
        LimeShader.setTexture(program, "image", 0, image.texture);
        LimeShader.setFloat4(program, "color", color.x, color.y, color.z, color.w);
        LimeShader.setInt(program, "radius", thickness);
        LimeShader.setFloat2(program, "offset", offset.x, offset.y);
        // LimeShader.setFloat2(program, "bounds", surface.getActualWidth(), surface.getActualHeight());
        LimeShader.setFloat2(program, "bounds", surface.getWidth(), surface.getHeight());
    }

    override public function setSurface(surface:Surface) {
        image = cast surface;
    }

    override function setColor(color:Color) {
        this.color.load(crovown.types.Color.fromARGB(color));
    }

    override function setThickness(thickness:Int) {
        this.thickness = thickness;
    }

    override public function setOffset(dx:Float, dy:Float) {
        this.offset.set(dx, dy);
    }
}


class LimeSdfShader extends SdfShader {
    public var program(default, null):GLProgram = null;
    var bounds = new Rectangle();
    var image:LimeSurface = null;
    var color = new Vector(1, 1, 1, 1);
    var threshold = 0.5;
    var contrast = 0.3;

    public function new(structure:AttributeStructure) {
        program = LimeShader.createProgram(structure.generateVertex(), "
            in vec3 pos;
            in vec4 col;
            in vec2 uv;

            uniform sampler2D image;
            uniform vec4 color;
            uniform float threshold;
            uniform float contrast;

            out vec4 frag;

            float lerp(float t, float x0, float y0, float x1, float y1) {
                return y0 + (t - x0) * (y1 - y0) / (x1 - x0);
            }

            void main() {
                // without smooth
                // if (texture(image, uv).y > threshold) {
                //     frag = color;
                // } else {
                //     // frag = vec4(0, 0, 0, 0);
                //     discard;
                // }

                // @todo condition

                // with smooth
                if (texture(image, uv).x > threshold) {
                    float d = lerp(texture(image, uv).x, threshold, 0.0, 0.6, 1.0);
                    d = pow(d, contrast);
                    // frag = vec4(d, d, d, 1.0) * color;
                    // frag = color * vec4(1.0, 1.0, 1.0, d);
                    frag = color * vec4(1.0, 1.0, 1.0, clamp(d, 0.0, 1.0));
                } else {
                    discard;
                }
                // if (texture(image, uv).y > threshold) {
                //     // float d = lerp(texture(image, uv).x, threshold, 0.0, 0.6, 1.0);
                //     float d = texture(image, uv).y;
                //     frag = vec4(1.0, 1.0, 1.0, 0.1);
                // } else {
                //     discard;
                // }


                /*
                float col = 0.0;
                int samples = 6;
                int diam = samples * 2;
                for (int i = 0; i < diam * diam; ++i) {
                    float dx = float(i / diam - samples) / 600.0;
                    float dy = float(i % diam - samples) / 600.0;
                    col += texture(image, uv + vec2(dx, dy)).y > threshold ? 1.0 : 0.0;
                    // col += step(threshold, texture(image, uv + vec2(dx, dy)).y);
                }
                frag = color * vec4(1.0, 1.0, 1.0, col / 8.0);
                */
            }
        ");
        structure.bind(program);
    }
    
    override function setSurface(surface:Surface) {
        image = cast surface;
    }

    override function setColor(color:Color) {
        this.color.load(crovown.types.Color.fromARGB(color));
    }

    override function setThreshold(threshold:Float) {
        this.threshold = threshold;
    }

    override function setContrast(contrast:Float) {
        this.contrast = contrast;
    }

    override function apply(surface:Surface) {
        var surface = cast(surface, LimeSurface);
        surface.useProgram(program);
        LimeShader.setMatrix4(program, "mvp", surface.getLimeTransform());
        LimeShader.setTexture(program, "image", 0, image.texture);
        LimeShader.setFloat4(program, "color", color.x, color.y, color.z, color.w);
        LimeShader.setFloat(program, "threshold", threshold);
        LimeShader.setFloat(program, "contrast", contrast);
    }
}