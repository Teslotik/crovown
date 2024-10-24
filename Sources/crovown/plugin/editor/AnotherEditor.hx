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
using crovown.component.filter.Filter;
using crovown.component.filter.SequenceFilter;
using crovown.component.filter.BlurFilter;
using crovown.component.filter.OutlineFilter;
using StringTools;

/*
- заменить поиск от корня на поиск от root'а редактора
*/

typedef AnotherTheme = {
    // Color
    background:Int,
    panel:Int,
    outline:Int,
    property:Int,
    accent:Int,
    text:Int,

    // Size
    header:Int,
    title:Int,
    padding:Int,
    insets:Int,
    size:Int,
    width:Int,
    gap:Int,
    spacing:Int,
    radius:Int,

    // Surfaces
    icons:Surface
}

#if editor
@:build(crovown.Macro.plugin(true))  // @todo
// @:build(crovown.Macro.plugin(false))
#else
@:build(crovown.Macro.plugin(false))
#end
class AnotherEditor extends Plugin {
    public var tree:Component = null;
    public var theme:AnotherTheme = null;
    
    override function onEnable(crow:Crovown) {
        crow.rule(component -> {
            if (component.getType() != TextWidget.type) return;
            var text = cast(component, TextWidget);
            text.color = Color(text.isActive ? theme.accent : theme.text);
            text.font = Assets.font_Inter;
            text.size = theme.title;
        });

        crow.rule(component -> {
            if (component.getType() != TreeItem.type) return;
            var tree = cast(component, TreeItem);
            tree.color = Color(Transparent);
            tree.horizontal = Fill;
            tree.vertical = Hug;
            tree.gap = Fixed(theme.gap);
        });

        crow.rule(component -> {
            if (component.getType() != SpacerWidget.type) return;
            var spacer = cast(component, SpacerWidget);
            spacer.color = Color(theme.background);
        });

        crow.rule(component -> {
            if (component.label != "selected") return;
            var text = cast(component, TextWidget);
            text.color = Color(theme.accent);
        });

        crow.rule(component -> {
            if (component.label != "icon") return;
            var icon = cast(component, Widget);
            icon.horizontal = Fixed(theme.size);
            icon.vertical = Fixed(theme.size);
        });

        crow.rule(component -> {
            if (component.label != "input-box") return;
            var property = cast(component, LayoutWidget);
            property.color = Color(theme.property);
            property.horizontal = Fill;
            property.vertical = Fixed(theme.size);
            property.borderWidth = All(theme.width);
            property.borderColor = Color(theme.outline);
            property.borderRadius = All(theme.radius);
            property.paddingLeft = theme.insets;
            property.vjustify = 0;
        });

        crow.rule(component -> {
            if (component.label != "control") return;
            var control = cast(component, LayoutWidget);
            control.color = Color(theme.property);
            control.horizontal = Hug;
            control.vertical = Fixed(theme.size);
            control.borderWidth = All(theme.width);
            control.borderColor = Color(theme.outline);
            control.borderRadius = All(theme.radius);
            control.paddingLeft = theme.insets;
            control.vjustify = 0;
        });

        crow.rule(component -> {
            if (component.label != "tools") return;
            var toolbar = cast(component, LayoutWidget);
            toolbar.color = Color(theme.panel);
            toolbar.direction = Row;
            toolbar.vertical = Fixed(theme.header);
            toolbar.horizontal = Fill;
            toolbar.padding = theme.padding;
            toolbar.vjustify = 0;
        });

        crow.rule(component -> {
            if (component.label != "group") return;
            var group = cast(component, LayoutWidget);
            group.color = Color(Transparent);
            group.direction = Column;
            group.vertical = Hug;
            group.horizontal = Fill;
            group.padding = theme.padding;
            group.gap = Fixed(theme.gap);
        });

        crow.application.onLoad = app -> {
            theme = {
                background: 0xFF0F0F0F,
                panel: 0xFF242424,
                outline: 0xFF3B3B3B,
                property: 0xFF121212,
                accent: 0xFFA6DC26,
                text: 0xFFA6A6A6,
    
                header: 48,
                title: 12,
                padding: 16,
                insets: 8,
                size: 22,
                width: 1,
                gap: 6,
                spacing: 8,
                radius: 4,
                
                icons: app.backend.loadImage(Assets.image_icons)
            }

            // @todo only in debug
            app.onRender.subscribe(app -> tree?.dispatch(new ValidateEvent()), Priority.Highest);
            app.framerate = 60;

            tree = crow.Component(component -> {
                component.animation = crow.SequenceAnimation([
                    crow.Animation(animation -> {
                        animation.label = "holding";
                        animation.duration = 0.8;
                        animation.isLooped = true;
                        animation.easing = Easing.easeInOutLinear;
                        animation.onFrameChanged = (animation, progress) -> {
                            var widget = cast(animation.data, Widget);
                            var amplitude = 4;
                            widget.transform = Matrix.Translation(
                                Math.sin(progress * 2 * Math.PI) * amplitude,
                                Math.cos(progress * 2 * Math.PI) * amplitude
                            );
                        }
                        animation.onEnd = animation -> {
                            var widget = cast(animation.data, Widget);
                            widget.transform = Matrix.Identity();
                        }
                    })
                ]);
            }, [
                crow.StageGui([
                    crow.LayoutWidget(layout -> {
                        layout.direction = Column;
                        layout.color = Color(theme.background);
                        layout.gap = Fixed(theme.gap);
                        // layout.transform = Matrix.Scale(1.2, 1.2);
                    }, [
                        crow.LayoutWidget(layout -> {
                            layout.label = "titlebar";
                            layout.color = Color(Transparent);
                            layout.direction = Row;
                            layout.vertical = Fixed(theme.header + 14);
                            layout.vjustify = 0;
                            layout.padding = theme.padding;
                            layout.gap = Even;
                        }, [
                            crow.LayoutWidget(layout -> {
                                layout.label = "menus";
                                layout.color = Color(Transparent);
                                layout.direction = Row;
                                layout.vertical = Hug;
                                layout.horizontal = Hug;
                                layout.gap = Fixed(theme.gap);
                            }, [
                                crow.TextWidget(text -> {
                                    text.text = "File";
                                }),
                                crow.TextWidget(text -> {
                                    text.text = "Edit";
                                }),
                                crow.TextWidget(text -> {
                                    text.text = "Run";
                                }),
                                crow.TextWidget(text -> {
                                    text.text = "View";
                                }),
                                crow.TextWidget(text -> {
                                    text.text = "Help";
                                })
                            ]),
                            crow.LayoutWidget(layout -> {
                                layout.color = Color(theme.property);
                                layout.horizontal = Fixed(200);
                                layout.vertical = Fixed(theme.size);
                                layout.borderWidth = All(theme.width);
                                layout.borderColor = Color(theme.outline);
                                layout.borderRadius = All(theme.size / 2);
                                layout.vjustify = 0;
                                layout.paddingLeft = theme.padding;
                            }, [
                                crow.TextWidget(text -> {
                                    text.text = "Search";
                                })
                            ]),
                            crow.TextWidget(text -> {
                                text.text = "Crovown Engine v0.641";
                            })
                        ]),
                        crow.LayoutWidget(layout -> {
                            layout.label = "header";
                            layout.color = Color(Transparent);
                            layout.direction = Column;
                            layout.vertical = Hug;
                            layout.horizontal = Fill;
                            layout.gap = Fixed(theme.width);
                        }, [
                            crow.LayoutWidget(layout -> {
                                layout.label = "tabs";
                                layout.color = Color(Transparent);
                                layout.direction = Row;
                                layout.vertical = Fixed(theme.header);
                                layout.horizontal = Fill;
                            }, [
                                crow.LayoutWidget(layout -> {
                                    layout.label = "tab";
                                    layout.color = Color(theme.panel);
                                    layout.direction = Row;
                                    layout.vertical = Fill;
                                    layout.horizontal = Hug;
                                    layout.padding = theme.padding;
                                    layout.minW = 150;
                                }, [
                                    crow.TextWidget(text -> {
                                        text.text = "Street";
                                    })
                                ]),
                                crow.LayoutWidget(layout -> {
                                    layout.label = "tab";
                                    layout.color = Color(Transparent);
                                    layout.direction = Row;
                                    layout.vertical = Fill;
                                    layout.horizontal = Hug;
                                    layout.padding = theme.padding;
                                    layout.minW = 150;
                                }, [
                                    crow.TextWidget(text -> {
                                        text.text = "House";
                                    })
                                ])
                            ]),
                            crow.LayoutWidget(layout -> {
                                layout.label = "tools";
                            }, [
                                crow.TextWidget(text -> {
                                    text.text = "Favorites";
                                }),
                                crow.TextWidget(text -> {
                                    text.text = "Save";
                                })
                            ])
                        ]),
                        crow.LayoutWidget(layout -> {
                            layout.label = "editor";
                            layout.color = Color(Transparent);
                            layout.direction = Row;
                            layout.gap = Fixed(theme.gap);
                        }, [
                            crow.LayoutWidget(layout -> {
                                layout.label = "left-panel";
                                layout.color = Color(theme.panel);
                                layout.direction = Column;
                                layout.horizontal = Fixed(330);
                                layout.vertical = Fill;
                            }, [
                                crow.LayoutWidget(layout -> {
                                    layout.label = "tools";
                                }, [
                                    crow.Widget(widget -> {
                                        widget.label = "icon";
                                        widget.color = Tile(0, Icons.PlusSign, 1, 1 / Icons.size, theme.icons);

                                        widget.onInput = event -> {
                                            var area = widget.getArea();
                                            if (area.isReleased) {
                                                trace("Adding component to viewport");
                                                var view:Component = this.tree.get("view");

                                                function add(menu:Widget, x:Float, y:Float, pos = 0, items:Array<String>) {
                                                    var groups = new Map<String, Array<String>>();
                                                    for (item in items) {
                                                        // crovown.component.widget.TextWidget -> ["crovown", "component", "widget", "TextWidget"]
                                                        var components = item.split(".");
                                                        // if pos == 2, then ["crovown", "component", "widget", "TextWidget"] ->
                                                        // label = "crovown.component.widget";
                                                        var label = components.splice(0, pos + 1).join(".");
                                                        var group = groups.get(label);
                                                        if (group == null) {
                                                            group = [];
                                                            groups.set(label, group);
                                                        }
                                                        // if pos == 2, then
                                                        // "crovown.component.widget" => ["crovown.component.widget.TextWidget"]
                                                        if (components.length > 0) group.push(item);
                                                    }

                                                    menu.addChild(crow.MenuWidget(menu -> {
                                                        menu.color = Color(Transparent);
                                                        menu.posX = x;
                                                        menu.posY = y;
                                                        menu.horizontal = Hug;
                                                        menu.vertical = Hug;
                                                        menu.delegate = crow.LayoutWidget(layout -> {
                                                            layout.color = Color(theme.property);
                                                            layout.vertical = Hug;
                                                            layout.horizontal = Hug;
                                                            layout.direction = Column;
                                                            layout.borderColor = Color(theme.outline);
                                                            layout.borderWidth = All(theme.width);
                                                            layout.borderRadius = All(theme.radius);
                                                            layout.padding = theme.insets;
                                                            layout.gap = Fixed(theme.gap);
                                                            layout.onInput = event -> {
                                                                var area = layout.getArea();
                                                                return !area.isOver;
                                                            }
                                                            layout.children = [for (item in groups.keyValueIterator()) crow.TextWidget(text -> {
                                                                text.text = item.key.split(".")[pos];
                                                                text.align = -1;
                                                                text.onInput = event -> {
                                                                    var area = text.getArea();
                                                                    if (area.isEntered) {
                                                                        menu.removeChildren();
                                                                        if (item.value.length > 0) {
                                                                            add(menu, x + layout.w, text.y, pos + 1, item.value);
                                                                        }
                                                                    }
                                                                    if (area.isReleased && item.value.length == 0) {
                                                                        var outliner:Component = this.tree.get("outliner");
                                                                        var tree = Lambda.find(outliner, c -> c.isActive) ?? outliner;
                                                                        var active = Lambda.find(view, c -> c.id == tree.id) ?? view;
                                                                        var info = Component.factory.get(item.key);
                                                                        active.addChild(info.builder(crow).callFactory(crow));
                                                                    }
                                                                    return true;
                                                                }
                                                            })];
                                                        });
                                                    }));
                                                }
                                                var menu:Widget = tree.get("menu");
                                                add(menu, event.mouse.x, event.mouse.y, 2, [for (k in Component.factory.keys()) k]);
                                            }
                                            return true;
                                        }
                                    }),
                                    crow.Widget(widget -> {
                                        widget.label = "icon";
                                        widget.color = Tile(0, Icons.Close, 1, 1 / Icons.size, theme.icons);

                                        widget.onInput = event -> {
                                            var area = widget.getArea();
                                            if (area.isReleased) {
                                                var view:Component = this.tree.get("view");
                                                var outliner:Component = this.tree.get("outliner");
                                                var active = Lambda.find(outliner, c -> c.isActive);
                                                if (active == null) return true;
                                                var component:Component = Lambda.find(view, i -> i.id == active.id);
                                                component.parent = null;
                                            }
                                            return true;
                                        }
                                    }),
                                ]),
                                crow.SpacerWidget(),
                                crow.TreeItem(tree -> {
                                    tree.url = "outliner";
                                    tree.padding = theme.padding;
                                    // tree.filter = crow.OutlineFilter(outline -> {
                                    //     outline.thickness = 1;
                                    //     outline.dx = 10;
                                    //     outline.dy = 10;
                                    // });
                                }, {
                                    onReady: tree -> {
                                        var tree = cast(tree, TreeItem);
                                        var view:Component = this.tree.get("view");
                                        function makeItem(widget:Widget, t:TreeItem, ?comp:Component) {
                                            widget.onInput = event -> {
                                                var area = widget.getArea();
                                                if (area.isReleased) {
                                                    for (c in tree) c.isActive = false;
                                                    for (c in view) c.isActive = false;
                                                    t.isActive = true;
                                                    if (comp != null) comp.isActive = true;
                                                    var properties:LayoutWidget = this.tree.get("properties");
                                                    properties.removeChildren();
                                                    view.dispatch(new PropertiesEvent(crow, properties));
                                                }
                                                
                                                if (area.dragStarted) {
                                                    var animation:Animation = this.tree.animation.search("holding");
                                                    animation.data = t;
                                                    animation.play(crow);
                                                }
                                                if (area.isDropped) {
                                                    var animation:Animation = this.tree.animation.search("holding");
                                                    animation.stop(crow);
                                                }
    
                                                return true;
                                            }
                                        }
                                        tree.delegate = item(crow, "Root", widget -> makeItem(widget, tree));
    
                                        function sync(component:Component, force = false) {
                                            app.delay(app -> {
                                                var view = this.tree.get("view");
                                                if (view == null) return;
                                                if (!force && !component.isParent(view)) return;
                                                trace("Synced");
                                                tree.synchronize(crow, view, (comp:Component) -> {
                                                    return crow.TreeItem(t -> {
                                                        t.id = comp.id;
                                                        t.delegate = item(crow, comp.getType(), widget -> makeItem(widget, t, comp));
                                                    });
                                                }, (a, b) -> a.id == b.id);
                                            });
                                        }
                                        Component.onParent.subscribe(tree, (component:Component) -> {
                                            sync(component);
                                        });
                                        Component.onUnparent.subscribe(tree, (component:Component) -> {
                                            sync(component, true);
                                        });

                                    }
                                })
                            ]),
                            crow.LayoutWidget(layout -> {
                                layout.label = "viewport";
                                layout.color = Color(theme.panel);
                                layout.direction = Column;
                                layout.horizontal = Fill;
                                layout.vertical = Fill;
                            }, [
                                crow.LayoutWidget(layout -> {
                                    layout.label = "tools";
                                }, [
                                    crow.Widget(widget -> {
                                        widget.label = "icon";
                                        widget.color = Tile(0, Icons.PlusSign, 1, 1 / Icons.size, theme.icons);
                                    }),
                                    crow.Widget(widget -> {
                                        widget.label = "icon";
                                        widget.color = Tile(0, Icons.Close, 1, 1 / Icons.size, theme.icons);
                                    }),
                                ]),
                                crow.ViewportWidget(viewport -> {
                                    viewport.url = "view";
                                    viewport.vertical = Fill;
                                    viewport.horizontal = Fill;
                                    viewport.clip = true;    // @todo
                                })
                            ]),
                            crow.LayoutWidget(layout -> {
                                layout.label = "right-panel";
                                layout.url = "properties";
                                layout.color = Color(theme.panel);
                                layout.direction = Column;
                                layout.horizontal = Fixed(330);
                                layout.vertical = Fill;
                                // layout.filter = crow.BlurFilter();
                            })
                        ])
                    ]),
                    crow.Widget(widget -> {
                        widget.url = "menu";
                        widget.color = Color(Transparent);
                        widget.onInput = event -> {
                            var area = widget.getArea();
                            if (area.isOver) {
                                widget.removeChildren();
                            }
                            return widget.children.length == 0;
                        }
                    })
                ])
            ]);
        }

    }

    public function item(crow:Crovown, title:String, isActive = false, ?build:Widget->Void) {
        var tree = crow.LayoutWidget(layout -> {
            layout.label = "container";
            // layout.color = Color(theme.property);
            layout.color = Color(Transparent);
            layout.horizontal = Fill;
            layout.vertical = Hug;
            layout.padding = theme.insets;
            // layout.borderRadius = All(theme.radius);
            // if (onClick != null) {
            //     layout.onInput = event -> {
            //         var area = layout.getArea();
            //         if (area.isReleased) return onClick(layout);
            //         return true;
            //     }
            // }
        }, [
            crow.TextWidget(text -> {
                text.text = title;
                text.onInput = event -> {
                    // @todo instead of polling parent.parent - pass tree as a function argument
                    text.color = Color(text.parent.parent.isActive ? theme.accent : theme.text);
                    return true;
                }
            })
        ]);
        build(tree);
        return tree;
    }
}