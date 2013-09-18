package com.timoff.utilites {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.geom.Matrix;

public class ImageUtils {

    public static function resize(width:int, height:int, source:BitmapData, propotional:Boolean = true):Bitmap {

        var scaleX:Number = width / source.width;
        var scaleY:Number = height / source.height

        if (propotional) {
            var scale:Number = (scaleX > scaleY) ? scaleY : scaleX;
            scaleX = scale;
            scaleY = scale;
        }

        var matrix:Matrix = new Matrix();
        matrix.scale(scaleX, scaleY);

        var bitmapData:BitmapData = new BitmapData(source.width * scaleX, propotional ? height: height * scaleY, true, 0x000000);
        bitmapData.draw(source, matrix, null, null, null, true);

        var result:Bitmap = new Bitmap(bitmapData, PixelSnapping.NEVER, true);
        return result;
    }

    public static function resizeHq(width:uint, height:uint, bitmapData:BitmapData, propotional:Boolean = true):Bitmap {
        var result:Bitmap;
        var finalScale:Number = Math.min(width / bitmapData.width,
                height / bitmapData.height);

        var finalData:BitmapData = bitmapData;

        if (finalScale > 1) {
            finalData = new BitmapData(bitmapData.width * finalScale,
                    bitmapData.height * finalScale, true, 0);

            finalData.draw(bitmapData, new Matrix(finalScale, 0, 0,
                    finalScale), null, null, null, true);

            result = new Bitmap(finalData, PixelSnapping.NEVER, true);
            return result;
        }

        var drop:Number = .5;
        var initialScale:Number = finalScale;

        while (initialScale / drop < 1)
            initialScale /= drop;

        var w:Number = Math.floor(bitmapData.width * initialScale);
        var h:Number = Math.floor(bitmapData.height * initialScale);
        var bd:BitmapData = new BitmapData(w, h, bitmapData.transparent, 0);

        bd.draw(finalData, new Matrix(initialScale, 0, 0, initialScale),
                null, null, null, true);
        finalData = bd;

        for (var scale:Number = initialScale * drop;
             Math.round(scale * 1000) >= Math.round(finalScale * 1000);
             scale *= drop) {
            w = Math.floor(bitmapData.width * scale);
            h = Math.floor(bitmapData.height * scale);
            bd = new BitmapData(w, h, bitmapData.transparent, 0);

            bd.draw(finalData, new Matrix(drop, 0, 0, drop), null, null, null, true);
            finalData.dispose();
            finalData = bd;
        }

        result = new Bitmap(finalData, PixelSnapping.NEVER, true);
        return result;
    }

}
}