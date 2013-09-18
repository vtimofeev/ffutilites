package com.timoff.utilites {
import flash.display.*;
import flash.system.ApplicationDomain;

public class Library {

    public function Library() {
    }

    //////////////////////////////////////////////////////////////////
    // Static methods
    /////////////////////////////////////////////////////////////////

    /**
     * Create object that's included to loaded library swfs or app swf
     *
     * @param className
     * @return
     *
     */
    public static function createInstanceByName(className:String):Object {
        var instance:Object;

        try {
            const cls:Class = ApplicationDomain.currentDomain.getDefinition(className) as Class;
            instance = new cls();
        }
        catch(error:Error) {
            trace("Lib::CreateInstanceByName error while creating " + className + " object");
            return null;
        }

        return instance;
    }

    /**
     * Library.createInstanceByName wrapper . It's used  to get from library DisplayObject
     *
     * @param className
     * @return MovieClip
     *
     */
    public static function createDisplayObjectByName(className:String):DisplayObject {
        var object:Object = createInstanceByName(className);

        trace("object is BitmapData " + (object is BitmapData) + " for " + className);
        if ((object is BitmapData)) {
            return new Bitmap(object as BitmapData);
        } else {
            return object as DisplayObject;
        }
    }


    /**
     * Library.createInstanceByName wrapper . It's used  to get from library Sprite
     *
     * @param className
     * @return Sprite
     *
     */
    public static function createSpriteByName(className:String):Sprite {
        return createInstanceByName(className) as Sprite;
    }

    /**
     * Library.createInstanceByName wrapper . It's used  to get from library MovieClip
     *
     * @param className
     * @return MovieClip
     *
     */
    public static function createMovieClipByName(className:String):MovieClip {
        return createInstanceByName(className) as MovieClip;
    }

}
}