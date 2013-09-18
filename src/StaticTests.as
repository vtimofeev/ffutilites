/**
 * Created by IntelliJ IDEA.
 * User: user
 * Date: 14.03.12
 * Time: 19:00
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.display.Sprite;
import flash.system.System;
import flash.utils.getTimer;

public class StaticTests  extends Sprite {
    public function StaticTests() {
        test();
    }

    var a:int = 0;
    var b:int = 10;
    var c:int = 10;
    var d:String = "hw:";


    private function test():void {
        const attemtps:int = 1000000;
        var i:int = 0;
        var time:Number = getTimer();
        var a:Vector.<*> = new Vector.<*>();

        trace("Start:: ", (getTimer() - time), System.totalMemory);

        for (i = 0; i < attemtps ; i++)
        {
           a.push(new LocalStaticObject());
        }

        trace("Local:: ", (getTimer() - time), System.totalMemory);
        return;

        time = getTimer();

        for (i = 0; i < attemtps ; i++)
        {
            testStaticLocal(a, b, c, d);
        }


        trace("Static:: ", (getTimer() - time));

    }

    function testLocal(_a:int,_b:int,_c:int,_d:String):int
    {
        var f:int = (_a + _b + _c );
        f +=  _a + _b + _c;
        return  f;
    }
    function testLocal2(_a:int,_b:int,_c:int,_d:String):int
    {
        var f:int = (_a + _b + _c );
        f +=  _a + _b + _c;
        return  f;
    }
    function testLocal3(_a:int,_b:int,_c:int,_d:String):int
    {
        var f:int = (_a + _b + _c );
        f +=  _a + _b + _c;
        return  f;
    }
    function testLocal4(_a:int,_b:int,_c:int,_d:String):int
    {
        var f:int = (_a + _b + _c );
        f +=  _a + _b + _c;
        return  f;
    }
    function testLocal5(_a:int,_b:int,_c:int,_d:String):int
    {
        var f:int = (_a + _b + _c );
        f +=  _a + _b + _c;
        return  f;
    }







    static function testStaticLocal(a:int,b:int,c:int,d:String):int
    {
        var f:int = (a + b + c );
        f = f + a + b + c;
        return f;
    }


}
}
