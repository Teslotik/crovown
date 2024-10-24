package crovown.plugin;

/*
import lime.utils.UInt32Array;
import lime.utils.Float32Array;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLVertexArrayObject;
import crovown.backend.LimeBackend;
import crovown.backend.Backend.ColoredShader;
import crovown.ds.Assets;
import crovown.algorithm.Easing;
import crovown.algorithm.MathUtils;
import crovown.backend.Backend.Font;
import crovown.ds.Matrix;
import crovown.types.Operation;
import lime.graphics.opengl.GL;

using crovown.component.Component;
using crovown.component.RegistryComponent;
using crovown.component.animation.Animation;
using crovown.component.animation.Animation;
using crovown.component.animation.SequenceAnimation;
using crovown.component.filter.AdjustColorFilter;
using crovown.component.filter.Filter;
using crovown.component.filter.SequenceFilter;
using crovown.component.network.Network;
using crovown.component.widget.BoxWidget;
using crovown.component.widget.LayoutWidget;
using crovown.component.widget.StageGui;
using crovown.component.widget.TextWidget;
using crovown.component.widget.Widget;
using crovown.component.widget.SpacerWidget;
using crovown.component.widget.SplitWidget;
using crovown.component.widget.AspectWidget;
*/

using crovown.component.Component;
using crovown.component.widget.StageGui;
using crovown.component.widget.LayoutWidget;

// class TestPlugin {
    
// }

/*
@:build(crovown.Macro.plugin(false))
class TestPlugin extends Plugin {
    override public function onEnable(crow:Crovown) {
        crow.application.onLoad = application -> {
            var tree = crow.Component({
                children: [
                    crow.StageGui({
                        label: "gui",
                        children: [
                            crow.LayoutWidget({
                                label: "croot",
                                horizontal: Fill,
                                vertical: Fill,
                                direction: Column,
                                posX: 5,
                                posY: 5,
                                padding: 20,
                                gap: Even,
                                vjustify: -1,
                                hjustify: -1,
                            })
                        ]
                    })
                ]
            });
        }
    }
}
*/

// @:build(crovown.Macro.plugin(false))
// class TestPlugin extends Plugin {
//     override public function onEnable(crow:Crovown) {
        // crow.application.onLoad = application -> {
        //     var tree = crow.Component({
        //         children: [
        //             crow.StageGui({
        //                 label: "gui",
        //                 children: [
        //                     crow.LayoutWidget({
        //                         label: "croot",
        //                         horizontal: Fill,
        //                         vertical: Fill,
        //                         direction: Column,
        //                         posX: 5,
        //                         posY: 5,
        //                         padding: 20,
        //                         gap: Even,
        //                         vjustify: -1,
        //                         hjustify: -1,
        //                     })
        //                 ]
        //             })
        //         ]
        //     });
        // }

        /*
        crow.application.onRender.subscribe("test", application -> {
            static var shader:ColoredShader = null;
            shader ??= crow.application.backend.shader(ColoredShader.label);
            crow.application.surface.clear(Aqua);
            // shader.setColor(crovown.types.Color.Magenta & 0x50FFFFFF);
            shader.setColor(0x62FF0000);
            crow.application.surface.setShader(shader);
            // crow.application.surface.pushTransform(Matrix.Translation(0, 0, -0.5));
            // crow.application.surface.drawRect(-1, -1, 2, 2);
            application.surface.drawTri(-0.5, -0.5, 0.5, -0.5, 0, 0.5);
            crow.application.surface.flush();
            application.surface.drawTri(-0.1, -0.5, 0.4, -0.5, 0.4, 0.5);
            crow.application.surface.flush();
            // crow.application.surface.clearTransform();
        });
        */
        
        /*
        var vao:GLVertexArrayObject = null;
        var vbo:GLBuffer = null;
        var ibo:GLBuffer = null;
        var shader:ColoredShader = null;

        var ready = false;
        crow.application.onRender.subscribe("test", application -> {
            static var shader:LimeColoredShader = null;
            shader ??= crow.application.backend.shader(ColoredShader.label);
            
            var screen:LimeSurface = cast application.surface;

            var gl = LimeBackend.gl;
            if (!ready) {
                ready = true;

                application.surface.drawTri(-0.5, -0.5, 0.5, -0.5, 0, 0.5);
    
                // vao = gl.createVertexArray();
                // vbo = gl.createBuffer();
                // ibo = gl.createBuffer();
                
    
                // gl.bindVertexArray(vao);
                
                // gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
                // var data = new Float32Array(60);
                // var z = -0.5;
                // data[0] = -0.5;
                // data[1] = -0.5;
                // data[2] = z;
                // data[3] = 0;
                // data[4] = 0;
    
                // data[5] = 0.5;
                // data[6] = -0.5;
                // data[7] = z;
                // data[8] = 1;
                // data[9] = 0;
    
                // data[10] = 0;
                // data[11] = 0.5;
                // data[12] = z;
                // data[13] = 1;
                // data[14] = 1;
                // gl.bufferData(gl.ARRAY_BUFFER, 15 * 4, data, gl.STATIC_DRAW);
    
                // gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibo);
                // var data = new UInt32Array(3);
                // data[0] = 0;
                // data[1] = 1;
                // data[2] = 2;
                // // bufferData 3 элемента * размер данных
                // // UInt32Array совпадает с gl.drawElements(gl.TRIANGLES, 3, gl.UNSIGNED_INT, 0);
                // gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, 3 * 4, data, gl.STATIC_DRAW);
    
                // gl.vertexAttribPointer(0, 3, gl.FLOAT, false, 2 * 4 + 3 * 4, 0);
                // gl.vertexAttribPointer(1, 2, gl.FLOAT, false, 2 * 4 + 3 * 4, 3 * 4);
                // gl.enableVertexAttribArray(0);
                // gl.enableVertexAttribArray(1);






                // gl.bindVertexArray(screen.structure.vao);

                // gl.bindBuffer(gl.ARRAY_BUFFER, screen.structure.vbo);
                // gl.bufferData(gl.ARRAY_BUFFER, 9 * 3 * 4, screen.structure.vertices, gl.STATIC_DRAW);
                
                // gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, screen.structure.ibo);
                // gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, 3 * 4, screen.structure.indices, gl.STATIC_DRAW);


                // screen.structure.setupStructure();
                screen.structure.build();

                // gl.vertexAttribPointer(0, 3, gl.FLOAT, false, (3 + 4 + 2) * 4, 0);
                // gl.vertexAttribPointer(1, 4, gl.FLOAT, false, (3 + 4 + 2) * 4, 3 * 4);
                // gl.vertexAttribPointer(1, 2, gl.FLOAT, false, (3 + 4 + 2) * 4, (3 + 4) * 4);

                // gl.enableVertexAttribArray(0);
                // gl.enableVertexAttribArray(1);
                
                // application.surface.flush();
            }
            
            gl.clearColor(0, 1, 1, 1.0);
            gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
            
            gl.useProgram(shader.program);
            LimeShader.setMatrix4(shader.program, "mvp", cast(application.surface, LimeSurface).getLimeTransform());
            LimeShader.setFloat4(shader.program, "color", 1, 1, 1, 1);

            // gl.bindVertexArray(vao);
            // gl.drawElements(gl.TRIANGLES, 3, gl.UNSIGNED_INT, 0);

            gl.bindVertexArray(screen.structure.vao);
            gl.drawElements(gl.TRIANGLES, 3, gl.UNSIGNED_INT, 0);
        });
        */
//     }
// }