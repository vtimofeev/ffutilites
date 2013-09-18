package com.timoff.utilites {
public class TimeUtils {
    
    public static function NumberToMMSS(value:Number):String
    {
        var time:int = int(value);
        var mm:int = Math.floor(time/60);
        var ss:int = time%60;

        var result:String = (mm<10)?"0"+mm.toString():mm.toString();
        result += ":";
        result += (ss<10)?"0"+ss.toString():ss.toString();
        
        return result;
    }

    public static function DateToHHMMSS(value:Date):String
    {
        var mm:int = Math.floor(value.getMinutes());
        var ss:int = value.getSeconds();
        var hh:int = value.getHours();

        var mmStr:String = (mm<10)?"0"+mm.toString():mm.toString();
        var ssStr:String = (ss<10)?"0"+ss.toString():ss.toString();
        var hhStr:String = (hh<10)?"0"+hh.toString():hh.toString();

        return hhStr + ":" + mmStr + ":" + ssStr;
    }
}
}