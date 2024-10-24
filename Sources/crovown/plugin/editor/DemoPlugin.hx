package crovown.plugin.editor;

import crovown.algorithm.Easing;
import crovown.types.Priority;
import crovown.event.ValidateEvent;
import crovown.event.PropertiesEvent;
import crovown.algorithm.MathUtils;
import crovown.ds.Vector;
import crovown.ds.Matrix;
import crovown.backend.Backend.Surface;
import crovown.ds.Assets;
import crovown.types.Icons;

using crovown.algorithm.StringUtils;
using crovown.component.Component;
using crovown.component.widget.StageGui;
using crovown.component.widget.Widget;
using crovown.component.widget.LayoutWidget;
using crovown.component.widget.BoxWidget;
using crovown.component.widget.SplitWidget;
using crovown.component.widget.SpacerWidget;
using crovown.component.widget.TextWidget;
using crovown.component.widget.TreeWidget.TreeItem;
using crovown.component.widget.ViewportWidget;
using crovown.component.widget.MenuWidget;
using crovown.component.spatial.TileMap;
using crovown.component.TileSet;
using crovown.component.animation.SequenceAnimation;
using crovown.component.animation.Animation;
using crovown.component.filter.AdjustColorFilter;
using crovown.component.filter.BlurFilter;
using crovown.component.filter.Filter;
using crovown.component.filter.SequenceFilter;
using StringTools;

/*
- заменить поиск от корня на поиск от root'а редактора
*/

// @todo
// #if editor
// #else
@:build(crovown.Macro.plugin(false))
// #end
// @:build(crovown.Macro.plugin(true))
// @:build(crovown.Macro.plugin(false))
class DemoPlugin extends Plugin {
    public var tree:Component = null;
    
    override function onEnable(crow:Crovown) {
        crow.rule(component -> {
            if (component.getType() != TextWidget.type) return;
            var text = cast(component, TextWidget);
            text.color = Color(White);
            text.font = Assets.font_Inter;
            text.size = 16;
        });

        crow.rule(component -> {
            if (component.getType() != TreeItem.type) return;
            var tree = cast(component, TreeItem);
            tree.color = Color(Transparent);
            tree.horizontal = Fill;
            tree.vertical = Hug;
            tree.gap = Fixed(5);
        });

        crow.rule(component -> {
            if (component.getType() != SpacerWidget.type) return;
            var spacer = cast(component, SpacerWidget);
            spacer.color = Color(Red);
        });

        crow.application.onLoad = app -> {
            // @todo only in debug
            // app.onRender.subscribe(app -> tree?.dispatch(new ValidateEvent()), Priority.Highest);
            app.framerate = 60;

            tree = crow.Component([
                crow.StageGui([
                    crow.LayoutWidget(layout -> {
                        layout.direction = Column;
                        layout.color = Color(Red);
                        layout.gap = Even;
                        layout.hjustify = 0;
                    }, [
                        crow.BoxWidget(box -> {
                            box.horizontal = Fixed(50);
                            box.vertical = Fixed(50);
                        }),
                        crow.BoxWidget(box -> {
                            box.label = "test";
                            // box.color = Color(Red);
                            box.color = Color(0xFFFF00FF);
                            // box.color = Color(0xFF00FF00);
                            box.horizontal = Fixed(50);
                            box.vertical = Fixed(50);
                            // box.filter = crow.Filter(filter -> {

                            // });
                            box.filter = crow.BlurFilter(filter -> {
                                // filter.clip = true;
                            });
                        }, [
                            // crow.BoxWidget(box -> {
                            //     box.left = Fixed(-10);
                            //     box.top = Fixed(-10);
                            //     box.horizontal = Fixed(50);
                            //     box.vertical = Fixed(50);
                            // })
                        ]),
                        // crow.BoxWidget(box -> {
                        //     box.horizontal = Fixed(50);
                        //     box.vertical = Fixed(50);
                        // }),
                    ])
                ])
            ]);
        }

    }
}