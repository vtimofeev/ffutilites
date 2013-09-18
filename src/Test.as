/**
 * @author vasily.timofeev@gmail.com
 */
package
{
    import flash.display.Sprite;
    import flash.utils.getTimer;

    public class Test extends Sprite
    {
        private var testVar:int = 2;
        public var testVar2:int = 3;

        public function Test()
        {
            tests();

        }

        private function tests():void
        {
            const iterations:int = 1000000;
            var startTm:Number = getTimer();

            for (var i:int = 0; i < iterations; i++)
            {
                method();
                method();
                method();
                method();
                method();
                method();
                method();
                method();
                method();
                method();
            }

            var tm:Number = getTimer() - startTm;
            trace(tm.toString());

            startTm = getTimer();

            for (var i:int = 0; i < iterations; i++)
            {
                smethod(testVar, testVar2);
                smethod(testVar, testVar2);
                smethod(testVar, testVar2);
                smethod(testVar, testVar2);
                smethod(testVar, testVar2);
                smethod(testVar, testVar2);
                smethod(testVar, testVar2);
                smethod(testVar, testVar2);
                smethod(testVar, testVar2);
                smethod(testVar, testVar2);

            }


            var tm2:Number  = getTimer() - startTm;
            trace((tm2 = getTimer() - startTm));
            trace((getTimer() - startTm));
           // throw new Error('test ' + tm + ", " + tm2);
        }


        private function method():int
        {
            return smethod(testVar, testVar2);
        }

        private static function smethod(a:int,  b:int):int
        {
            return a+b;
        }
    }
}
