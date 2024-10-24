package crovown.ds;

import crovown.component.Component;
import crovown.Crovown;

typedef Info = {
    name:String,
    isVisible:Bool, // specially in editor
    builder:Crovown->Component,
    canParent:Component->Bool,
    canChild:Component->Bool
}