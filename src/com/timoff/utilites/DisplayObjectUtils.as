/**
 * Author: Vasily Timofeev
 * Web: http://timoff.com
 */
package com.timoff.utilites {
import flash.display.DisplayObject;

public class DisplayObjectUtils {
    public static function resetDisplayObject(value:DisplayObject):void {
        if (!value) return;

        if(value.parent) value.parent.removeChild(value);
        if(value.alpha != 1) value.alpha = 1;
        if(!value.visible) value.visible = true;
        value.scaleX = value.scaleY = 1;
        value.x = value.y = 0;
        value.filters = [];
    }
}
}
