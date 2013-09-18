package com.timoff.services.log {
import com.timoff.services.html.*;

import flash.utils.getTimer;

public class LogDataObject extends Object {
    private var message:String = null;
    private var time:Number;
    private var type:int = 0x01;
    private var caller:Object;


    public function LogDataObject(message:String, type:int = 0x01, caller:* = null) {
        this.message = message;
        this.type = type;
        this.time = getTimer();
        this.caller = caller;

        super();
    }

    public function toString():String {

        var date:Date = new Date(time);
        var result:String = date.minutes + ":" + date.seconds + ":" + date.milliseconds + "', " + this.message + "\n";

        return result;
    }

    public function toHtmlString():String {

        var date:Date = new Date(time);
        var result:String = date.minutes + ":" + date.seconds + ":" + date.milliseconds + "', " + this.message + "\n";

        switch (type) {
            case Log.FATAL:
                result = HTMLWrapper.font(result, Log.FATAL_COLOR);
                break;
            case Log.ERROR:
                result = HTMLWrapper.font(result, Log.ERROR_COLOR);
                break;
            case Log.DEBUG:
                result = HTMLWrapper.font(result, Log.DEBUG_COLOR);
                break;
            default:
                result = HTMLWrapper.font(result, Log.INFO_COLOR);
                break;
        }

        return result;
    }

}
}