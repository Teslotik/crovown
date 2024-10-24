package crovown.plugin;

/*
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

class HelloWorldPlugin {
    
}

/*
@:build(crovown.Macro.plugin(false))    // true
class HelloWorldPlugin extends Plugin {
    public function new() {
        super();
    }

    override public function onEnable(crow:Crovown) {
        crow.application.onLoad = application -> {
            var tree = crow.Component({
                children: [
                    crow.RegistryComponent({
                        url: "registry",
                        onCreate: component -> {
                            var registry = cast(component, RegistryComponent);
                            registry.subscribe("test", () -> {
                                trace(registry.find("./gui"));
                            });
                        }
                    }),
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
                                // transform: Matrix.RotationZ(MathUtils.radians(30)),
                                // transform: Matrix.Translation(0, 100),
                                // transform: Matrix.Scale(1, 0.7),
                                padding: 20,
                                // wrap: true,
                                // gap: Fixed(10),
                                gap: Even,
                                vjustify: -1,
                                hjustify: -1,
                                // filter: crow.Filter({
                                            
                                // }),
                                children: [
                                    crow.Widget({
                                        // anchors: Fixed(60)
                                        // top: Fixed(60),
                                        // right: Fixed(60),
                                        // bottom: Center(0),
                                        // left: Fixed(60)
                                        borderRadius: All(5),
                                        borderWidth: All(5),
                                        horizontal: Fixed(100),
                                        vertical: Fixed(100),
                                        // borderColor: Color(Red),
                                        filter: crow.Filter({
                                            
                                        })
                                        // filter: crow.SequenceFilter({
                                        //     children: [
                                        //         crow.AdjustColorFilter({

                                        //         }),
                                        //         crow.Filter({

                                        //         })
                                        //     ]
                                        // })
                                    }),
                                    crow.SplitWidget({
                                        vertical: Fixed(40),
                                        pos: Scale(0.7),
                                        // onCreate: component -> {
                                        //     var widget = cast(component, Widget);
                                        //     trace(widget.horizontal, widget.vertical);
                                        // },
                                        splitter: crow.BoxWidget({
                                            // color: Color(Red),
                                            horizontal: Fixed(10),
                                            vertical: Fixed(10),
                                            children: [
                                                crow.Widget({
                                                    label: "drag",
                                                    color: Color(Red),
                                                    anchors: Center(40)
                                                })
                                            ],
                                            onReady: component -> {
                                                var splitter = cast(component, Widget);
                                                var split:SplitWidget = component.getParent();
                                                var drag:Widget = splitter.find("drag");
                                                split.drag = widget -> drag.getArea();
                                            }
                                        }),
                                        first: crow.BoxWidget({
                                            // horizontal: Fill,
                                            // vertical: Fill
                                        }),
                                        second: crow.BoxWidget({
                                            // horizontal: Fill,
                                            // vertical: Fill,
                                            onMouseInput: (widget, mouse) -> {
                                                // if (widget.getAABB().isDown) trace("a");
                                                var area = widget.getAABB();
                                                // if (area.isDragging) {
                                                //     trace("dragging", Math.random());
                                                // }
                                                if (area.isDragging) {
                                                    // trace("a", area.drag, area.drag.length(), Math.random());
                                                }
                                                // trace(area.isInsideArea, area.isEntered, area.isExit, Math.random());
                                                // trace(area.isHolding, Math.random());
                                                // if (area.)
                                                return true;
                                            }
                                        })
                                    }),
                                    // crow.BoxWidget({
                                    //     vertical: Fixed(10)
                                    // }),
                                    crow.BoxWidget({
                                        // anchors: Fixed(60)
                                        // top: Fixed(100),
                                        // right: Fixed(60),
                                        // bottom: Center(0),
                                        // left: Fixed(60),
                                        // transform: Matrix.Translation(0, 200),
                                        horizontal: Fixed(400),
                                        vertical: Fixed(100),
                                        // filter: crow.Filter({
                                            
                                        // })
                                    }),
                                    crow.TextWidget({
                                        // font: new Font("arial"),
                                        font: Assets.font_arial,
                                        text: "Test",
                                        // filter: crow.Filter({

                                        // }),
                                        pivotX: 1,
                                        pivotY: 1,
                                        transform: Matrix.RotationZ(MathUtils.radians(30)),
                                        animation: crow.Animation({
                                            isLooped: true,
                                            duration: 4,
                                            speed: 1,
                                            easing: Easing.easeInOutBounce,
                                            onStart: animation -> {
                                                // trace("started");
                                            },
                                            onEnd: animation -> {
                                                // trace("ended");
                                            },
                                            onFrameChanged: (animation, progress) -> {
                                                var text:TextWidget = animation.getParent();
                                                text.transform = Matrix.RotationZ(MathUtils.radians(MathUtils.lerp(progress, 0, 0, 1, 360)));
                                                // trace(progress, animation.duration, animation.elapsed);
                                                // trace("frame");
                                                // text.transform = Matrix.RotationZ(Math.sin(progress * Math.PI * 2 - Math.PI));
                                                // text.transform = Matrix.RotationZ(progress);
                                            }
                                        }),
                                        onCreate: component -> {
                                            component.animation.play(crow);
                                        }
                                    }),
                                    crow.BoxWidget({
                                        // horizontal: Fixed(570),
                                        borderRadius: All(5),
                                        borderWidth: All(5),
                                        horizontal: Fixed(100),
                                        vertical: Fixed(100),
                                        // filter: crow.Filter({
                                            
                                        // })
                                        // filter: crow.AdjustColorFilter({
                                            
                                        // }),
                                        pivotX: 1,
                                        pivotY: 1,
                                        filter: crow.SequenceFilter({
                                            children: [
                                                crow.AdjustColorFilter({

                                                }),
                                                crow.Filter({

                                                })
                                            ]
                                        }),
                                        animation: crow.SequenceAnimation({
                                            isLooped: true,
                                            children: [
                                                crow.Animation({
                                                    duration: 1,
                                                    onFrameChanged: (animation, progress) -> {
                                                        var seq:SequenceAnimation = animation.getParent();
                                                        var text:Widget = animation.getParent().getParent();
                                                        
                                                        seq.updateDuration();
                                                        text.transform = Matrix.RotationZ(MathUtils.radians(MathUtils.lerp(progress, 0, 0, 1, 360)));
                                                    }
                                                }),
                                                crow.Animation({
                                                    duration: 1,
                                                    onFrameChanged: (animation, progress) -> {
                                                        var seq:SequenceAnimation = animation.getParent();
                                                        var text:Widget = animation.getParent().getParent();
                                                        
                                                        seq.updateDuration();
                                                        text.transform = Matrix.RotationZ(MathUtils.radians(MathUtils.lerp(progress, 0, 0, 1, -360)));
                                                    }
                                                }),
                                                crow.Animation({
                                                    duration: 2,
                                                    easing: Easing.easeOutElastic,
                                                    onFrameChanged: (animation, progress) -> {
                                                        var text:Widget = animation.getParent().getParent();
                                                        var f = MathUtils.mix(progress, 1, 1.5);
                                                        text.transform = Matrix.Scale(f, f);
                                                        animation.speed = 3;
                                                    }
                                                })
                                            ]
                                        }),
                                        onCreate: component -> {
                                            component.animation.play(crow);
                                        },
                                    })
                                ]
                            })
                        ]
                    })
                ]
            });
            var registry:RegistryComponent = tree.get("registry");
            registry.emit("test");
        }
    }
}
*/