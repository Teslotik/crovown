package crovown.plugin.editor;

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
using crovown.component.widget.TextWidget;
using crovown.component.widget.TreeWidget.TreeItem;
using crovown.component.widget.ViewportWidget;
using crovown.component.widget.MenuWidget;
using crovown.component.spatial.TileMap;
using crovown.component.TileSet;

using StringTools;
using Lambda;

typedef Theme = {
    // Color
    background:Int,
    panel:Int,
    property:Int,
    accent:Int,
    text:Int,

    // Size
    panelWidth:Int,
    title:Int,
    size:Int,
    padding:Int,
    insets:Int,
    radius:Int,
    width:Int,
    gap:Int,
    spacing:Int,

    // Surfaces
    icons:Surface
}

@:build(crovown.Macro.plugin(false))
class EditorPlugin extends Plugin {
    public var tree:Component = null;
    public var theme:Theme = null;

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
            if (component.label != "header") return;
            var header = cast(component, LayoutWidget);
            header.color = Color(Transparent);
            header.horizontal = Fill;
            header.vertical = Hug;
            header.gap = Even;
        });

        crow.rule(component -> {
            if (component.label != "icon") return;
            var icon = cast(component, Widget);
            icon.horizontal = Fixed(theme.size);
            icon.vertical = Fixed(theme.size);
        });

        crow.rule(component -> {
            if (component.label != "toolbar") return;
            var toolbar = cast(component, LayoutWidget);
            toolbar.color = Color(theme.property);
            toolbar.horizontal = Hug;
            toolbar.vertical = Hug;
            toolbar.borderRadius = All(theme.radius);
            toolbar.padding = theme.insets;
            toolbar.gap = Fixed(theme.gap);
        });

        crow.application.onLoad = app -> {
            theme = {
                background: 0xFF171717,
                panel: 0xFF1F1F1F,
                property: 0xFF292929,
                accent: 0xFFA6DC26,
                text: 0xFFA7A7A7,
            
                panelWidth: 330,
                title: 14,
                size: 22,
                padding: 20,
                insets: 6,
                radius: 4,
                width: 2,
                gap: 4,
                spacing: 16,

                icons: app.backend.loadImage(Assets.image_icons)
            }

            tree = crow.Component([
                crow.StageGui(stage -> {

                }, {
                    children: [
                        crow.LayoutWidget(widget -> {
                            widget.color = Color(theme.background);
                        }, {
                            children: [
                                crow.SplitWidget(split -> {
                                    split.color = Color(Transparent);
                                    split.pos = Fixed(theme.panelWidth);

                                    split.splitter = crow.BoxWidget(box -> {
                                        box.color = Color(Transparent);
                                        box.horizontal = Fixed(20);
                                        box.vertical = Fixed(20);
                                    });

                                    split.first = crow.LayoutWidget(layout -> {
                                        layout.label = "hierarchy";
                                        layout.color = Color(theme.panel);
                                        layout.direction = Column;
                                        layout.padding = theme.padding;
                                        layout.gap = Fixed(theme.spacing);
                                    }, {
                                        children: [
                                            crow.LayoutWidget(layout -> {
                                                layout.label = "header";
                                            }, {
                                                children: [
                                                    crow.TextWidget(text -> {
                                                        text.text = "Opened";
                                                    }),
                                                    crow.LayoutWidget(layout -> {
                                                        layout.label = "toolbar";
                                                    }, {
                                                        children: [
                                                            crow.Widget(widget -> {
                                                                widget.label = "icon";
                                                                widget.color = Tile(0, Icons.PlusSign, 1, 1 / Icons.size, theme.icons);
                                                            }),
                                                            crow.Widget(widget -> {
                                                                widget.label = "icon";
                                                                widget.color = Tile(0, Icons.Close, 1, 1 / Icons.size, theme.icons);
                                                            }),
                                                        ]
                                                    })
                                                ]
                                            }),
                                            crow.TreeItem(tree -> {
                                                tree.delegate = item(crow, "Scene");
                                            }, {
                                                children: [
                                                    crow.TreeItem(tree -> {
                                                        tree.delegate = item(crow, "Player", true);
                                                    }),
                                                    crow.TreeItem(tree -> {
                                                        tree.delegate = item(crow, "Enemy");
                                                    })
                                                ]
                                            }),
                                            crow.LayoutWidget(layout -> {
                                                layout.label = "header";
                                            }, {
                                                children: [
                                                    crow.TextWidget(text -> {
                                                        text.text = "Outliner";
                                                    }),
                                                    crow.LayoutWidget(layout -> {
                                                        layout.label = "toolbar";
                                                    }, {
                                                        children: [
                                                            crow.Widget(widget -> {
                                                                widget.label = "icon";
                                                                widget.color = Tile(0, Icons.PlusSign, 1, 1 / Icons.size, theme.icons);
                                                                widget.onInput = event -> {
                                                                    var area = widget.getArea();

                                                                    if (area.isReleased) {
                                                                        // for (path in Component.factory.keys()) {
                                                                        //     trace(path.split(".").map(s -> s.capitalize()).join(" "));
                                                                        // }

                                                                        // Context menu for Components creation
                                                                        function add(menu:Widget, x:Float, y:Float, items:Array<String>, pos = 0) {
                                                                            // trace(items);
                                                                            // var view:Component = this.tree.get("view");
                                                                            // var outliner:Component = this.tree.get("outliner");
                                                                            // var tree = Lambda.find(outliner, c -> c.isActive);
                                                                            // if (tree != null) {
                                                                            //     var active = Lambda.find(view, c -> c.id == tree.id) ?? view;
                                                                            //     var info = Component.factory.get(items[0]);
                                                                            //     if (info.canParent(active)) {
                                                                            //         return;
                                                                            //     }
                                                                            // }

                                                                            menu.addChild(crow.MenuWidget(widget -> {
                                                                                widget.color = Color(Transparent);
                                                                                widget.horizontal = Hug;
                                                                                widget.vertical = Hug;
                                                                                widget.delegate = crow.LayoutWidget(layout -> {
                                                                                    layout.color = Color(theme.panel);
                                                                                    widget.x = x;
                                                                                    widget.y = y;
                                                                                    layout.horizontal = Hug;
                                                                                    layout.vertical = Hug;
                                                                                    layout.direction = Column;
                                                                                    layout.padding = theme.insets * 2;
                                                                                    layout.gap = Fixed(theme.gap + theme.insets * 2);
                                                                                    layout.borderColor = Color(theme.property);
                                                                                    layout.borderRadius = All(theme.radius);
                                                                                    layout.borderWidth = All(theme.width);

                                                                                    // Groupping items by the pos
                                                                                    // groupping items which has the same string's part at the position pos
                                                                                    var pairs = new Map<String, Array<String>>();
                                                                                    for (item in items) {
                                                                                        // example: crovown.component.widget.TextWidget ->
                                                                                        // [crovown, component, widget, TextWidget]
                                                                                        var parts = item.split(".");
                                                                                        // example: `widget` if pos == 2
                                                                                        // meaning we will group items which has widget at pos == 2
                                                                                        var name = parts[pos];

                                                                                        var group = pairs.get(name);
                                                                                        if (group == null) {
                                                                                            group = [];
                                                                                            pairs.set(name, group);
                                                                                        }
                                                                                        group.push(item);
                                                                                    }
                                                                                    
                                                                                    layout.children = [for (item in pairs.keyValueIterator()) crow.TextWidget(text -> {
                                                                                        text.text = item.key;
                                                                                        text.align = -1;

                                                                                        text.onInput = event -> {
                                                                                            var area = text.getArea();
                                                                                            if (area.isEntered) {
                                                                                                // Adding packages
                                                                                                widget.removeChildren();

                                                                                                // Checking parent possibility
                                                                                                // @todo refactor?
                                                                                                item.value = item.value.filter(i -> {
                                                                                                    if (i.split(".").length > pos + 2) return true;
                                                                                                    var view:Component = this.tree.get("view");
                                                                                                    var outliner:Component = this.tree.get("outliner");
                                                                                                    var tree = Lambda.find(outliner, c -> c.isActive);
                                                                                                    if (tree == null) return true;
                                                                                                    var active = Lambda.find(view, c -> c.id == tree.id) ?? view;
                                                                                                    var info = Component.factory.get(i);
                                                                                                    return info.canParent(active);
                                                                                                });

                                                                                                if (item.value[0].split(".").length > pos + 1) {
                                                                                                    add(widget, widget.x + widget.w, text.y, item.value, pos + 1);
                                                                                                }
                                                                                            }
                                                                                            if (area.isPressed) {
                                                                                                // Adding components
                                                                                                // @todo refactor?
                                                                                                if (item.value[0].split(".").length == pos + 1) {
                                                                                                    var view:Component = this.tree.get("view");
                                                                                                    var outliner:Component = this.tree.get("outliner");
                                                                                                    var tree = Lambda.find(outliner, c -> c.isActive);
                                                                                                    if (tree != null) {
                                                                                                        var active = Lambda.find(view, c -> c.id == tree.id) ?? view;
                                                                                                        var info = Component.factory.get(item.value[0]);
                                                                                                        active.addChild(info.builder(crow).callFactory(crow));
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                            return true;
                                                                                        }
                                                                                    })];
                                                                                });
                                                                            }));
                                                                        }

                                                                        var menu:Widget = tree.get("menu");
                                                                        // Number at the last position removes crovown.component from the path
                                                                        add(menu, widget.x, widget.y, [for (i in Component.factory.keys()) i], 2);
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
                                                                        // Removing components
                                                                        var view:Component = this.tree.get("view");
                                                                        var outliner:Component = this.tree.get("outliner");
                                                                        var active = outliner.filter(c -> c.isActive);
                                                                        for (item in active) {
                                                                            Lambda.find(view, c -> c.id == item.id)?.free();
                                                                        }
                                                                    }
                                                                    return true;
                                                                }
                                                            }),
                                                        ]
                                                    })
                                                ]
                                            }),
                                            crow.TreeItem(tree -> {
                                                tree.url = "outliner";
                                                tree.delegate = item(crow, "Game");
                                                function sync(component:Component, force = false) {
                                                    app.delay(app -> {
                                                        var view = this.tree.get("view");
                                                        if (view == null) return;
                                                        if (!force && !component.isParent(view)) return;
                                                        tree.synchronize(crow, view, (comp:Component) -> {
                                                            return crow.TreeItem(t -> {
                                                                t.id = comp.id;
                                                                t.delegate = item(crow, comp.getType(), widget -> {
                                                                    for (c in tree) c.isActive = false;
                                                                    t.isActive = true;
                                                                });
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
                                            }, {
                                                children: [
                                                    crow.TreeItem(tree -> {
                                                        tree.delegate = item(crow, "Scene 1", true);
                                                    }),
                                                    crow.TreeItem(tree -> {
                                                        tree.delegate = item(crow, "GUI");
                                                    })
                                                ]
                                            })
                                        ]
                                    });

                                    split.second = crow.LayoutWidget(layout -> {
                                        split.color = Color(Transparent);
                                    }, {
                                        children: [
                                            crow.LayoutWidget(layout -> {
                                                layout.color = Color(theme.background);
                                                layout.direction = Column;
                                                layout.padding = theme.padding;
                                                layout.gap = Fixed(theme.spacing);
                                            }, {
                                                children: [
                                                    crow.LayoutWidget(layout -> {
                                                        layout.label = "header";
                                                    }, {
                                                        children: [
                                                            crow.TextWidget(text -> {
                                                                text.text = "Viewport";
                                                            }),
                                                            crow.LayoutWidget({
                                                                label: "toolbar",
                                                                children: [
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Cursor, 1, 1 / Icons.size, theme.icons);
                                                                        widget.onInput = event -> {
                                                                            if (widget.getArea().isReleased) {
                                                                                // trace("a");
                                                                                // tree.dispatch(new DrawEvent(), true);
                                                                            }
                                                                            return true;
                                                                        }
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.CursorOutline, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Trashcan, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                ]
                                                            }),
                                                            crow.LayoutWidget({
                                                                label: "toolbar",
                                                                children: [
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Empty, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Tile, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Entity, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Light, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Sound, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Camera, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Path, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Script, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                ]
                                                            }),
                                                            crow.LayoutWidget({
                                                                label: "toolbar",
                                                                children: [
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.PlusSign, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Close, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                ]
                                                            }),
                                                            crow.LayoutWidget({
                                                                label: "toolbar",
                                                                children: [
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Settings, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                ]
                                                            })
                                                        ]
                                                    }),
                                                    // crow.LayoutWidget(layout -> {
                                                    //     layout.horizontal = Fi
                                                    // })
                                                    crow.BoxWidget(box -> {
                                                        box.label = "viewport";
                                                        box.color = Color(Transparent);
                                                        box.horizontal = Fill;
                                                        box.vertical = Fill;
                                                    }, {
                                                        children: [
                                                            // crow.LayoutWidget(layout -> {
                                                            //     layout.label = "dock";
                                                            //     layout.color = Color(theme.panel);
                                                            //     layout.bottom = Fixed(theme.padding);
                                                            //     layout.vertical = Hug;
                                                            //     layout.horizontal = Hug;
                                                            // }, {
                                                            //     children: [
                                                            //         crow.TextWidget(text -> text.text = "Dock"),
                                                            //         crow.TextWidget(text -> text.text = "<-"),
                                                            //         crow.TextWidget(text -> text.text = "O"),
                                                            //         crow.TextWidget(text -> text.text = "T")
                                                            //     ]
                                                            // })

                                                            crow.ViewportWidget(viewport -> {
                                                                viewport.url = "view";
                                                                viewport.anchors = Fixed(0);
                                                                viewport.camera = Matrix.Translation(0, 0);
                                                                viewport.unit = 24;
                                                                viewport.clip = true;
                                                                viewport.onInput = event -> {
                                                                    var parent:Widget = viewport.getParent();

                                                                    var area = parent.getArea();

                                                                    if (area.isPressed) {
                                                                        var tilemap:TileMap = viewport.search("tilemap");
                                                                        var area = parent.getArea();
                                                                        var local = viewport.toLocal(area.mouseLocal.x, area.mouseLocal.y);
                                                                        tilemap.setTile(Math.floor(local.x + tilemap.size / 2), Math.floor(local.y + tilemap.size / 2), 4);
                                                                    }

                                                                    static var deltaMove = new Vector();
                                                                    static var deltaScroll = 0.0;

                                                                    if (area.isPressed) deltaMove.zeros();
                                                                    if (area.isDragging) deltaMove.addVal(area.mouseDelta.x, area.mouseDelta.y);
                                                                    if (area.isOver) deltaScroll += (event.mouse.wheelDeltaY + event.mouse.wheelDeltaX) * 0.25;

                                                                    var deceleration = 8.0;
                                                                    var offsetX = deltaMove.x * MathUtils.clamp(deceleration * app.deltaTime, -1, 1);
                                                                    var offsetY = deltaMove.y * MathUtils.clamp(deceleration * app.deltaTime, -1, 1);
                                                                    var offsetScroll = deltaScroll * MathUtils.clamp(deceleration * app.deltaTime, -1, 1);

                                                                    viewport.camera.translate(offsetX, offsetY);
                                                                    deltaMove.subVal(offsetX, offsetY);

                                                                    var scale = Matrix.Scale(1 + offsetScroll, 1 + offsetScroll).MultMat(viewport.camera);
                                                                    viewport.camera = scale;
                                                                    deltaScroll -= offsetScroll;
                                                                    return true;
                                                                }
                                                            }, {
                                                                children: [
                                                                    crow.TileMap(tilemap -> {
                                                                        tilemap.label = "tilemap";
                                                                        tilemap.color = Image(50, 50, theme.icons);
                                                                        tilemap.anchors = Fixed(0);
                                                                        // tilemap.width = 10;
                                                                        // tilemap.height = 10;
                                                                        tilemap.tileset = crow.TileSet(tileset -> {
                                                                            tileset.surface = app.backend.loadImage(Assets.image_spring_tilemap);
                                                                            tileset.width = 10;
                                                                            tileset.height = 15;
                                                                            tileset.size = 24;
                                                                        });
                                                                    }),
                                                                    // @todo create and test layers
                                                                    // crow.Widget(widget -> {
                                                                    //     widget.label = "layer";
                                                                    //     widget.color = Color(Red);
                                                                    // })
                                                                ]
                                                            }),

                                                            crow.LayoutWidget(layout -> {
                                                                layout.label = "context";
                                                                layout.color = Color(theme.panel);
                                                                layout.left = Fixed(0);
                                                                layout.right = Fixed(0);
                                                                layout.bottom = Fixed(0);
                                                                layout.vertical = Hug;
                                                                layout.padding = theme.padding;
                                                                layout.gap = Fixed(theme.gap);
                                                                layout.borderRadius = All(theme.radius);
                                                            }, {
                                                                children: [
                                                                    crow.TextWidget(text -> text.text = "Assets"),
                                                                    crow.TextWidget(text -> text.text = "Animation"),
                                                                    crow.TextWidget(text -> text.text = "Tileset"),
                                                                    crow.TextWidget(text -> text.text = "Drivers"),
                                                                    crow.TextWidget(text -> text.text = "Console"),
                                                                    crow.TextWidget(text -> text.text = "Profiler")
                                                                ]
                                                            })
                                                        ]
                                                    })
                                                ]
                                            }),
                                            crow.LayoutWidget(layout -> {
                                                layout.label = "properties";
                                                layout.color = Color(theme.panel);
                                                layout.horizontal = Fixed(theme.panelWidth);
                                                layout.direction = Column;
                                                layout.padding = theme.padding;
                                                layout.gap = Fixed(theme.spacing);
                                            }, {
                                                children: [
                                                    crow.LayoutWidget(layout -> {
                                                        layout.label = "header";
                                                    }, {
                                                        children: [
                                                            crow.TextWidget(text -> {
                                                                text.text = "Properties";
                                                            }),
                                                            crow.LayoutWidget(layout -> {
                                                                layout.label = "toolbar";
                                                            }, {
                                                                children: [
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.PlusSign, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                    crow.Widget(widget -> {
                                                                        widget.label = "icon";
                                                                        widget.color = Tile(0, Icons.Close, 1, 1 / Icons.size, theme.icons);
                                                                    }),
                                                                ]
                                                            })
                                                        ]
                                                    }),
                                                ]
                                            })
                                        ]
                                    });
                                })
                            ]
                        }),
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
                        }),
                        // @todo remove, used for tests
                        crow.Widget(widget -> widget.color = Color(Transparent)),
                        crow.Widget(widget -> widget.color = Color(Transparent))
                    ]
                })
            ]);
        }
    }

    public function item(crow:Crovown, title:String, isActive = false, ?onClick:Widget->Bool) {
        return crow.LayoutWidget(layout -> {
            layout.label = "container";
            layout.color = Color(theme.property);
            layout.horizontal = Fill;
            layout.vertical = Hug;
            layout.padding = theme.insets;
            layout.borderRadius = All(theme.radius);
            if (onClick != null) {
                layout.onInput = event -> {
                    var area = layout.getArea();
                    if (area.isReleased) return onClick(layout);
                    return true;
                }
            }
        }, {
            children: [
                crow.TextWidget(text -> {
                    text.isActive = isActive;
                    text.text = title;
                    text.onInput = event -> {
                        // @todo instead of polling parent.parent - pass tree as a function argument
                        text.color = Color(text.parent.parent.isActive ? theme.accent : theme.text);
                        return true;
                    }
                })
            ]
        });
    }
}