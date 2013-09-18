/**
 * @author vasily.timofeev@gmail.com
 */
package {
    import com.timoff.services.log.Log;
    import com.timoff.services.time.BasicTimer;
    import com.timoff.utilites.ObjectUtils;

    import flash.display.Sprite;
    import flash.utils.setTimeout;

    import com.timoff.services.test.BasicTest;

    public class BasicTimerTests extends Sprite
    {
        private var intervalResult:int = 0;
        private var timerResult:int = 0;
        private var timerCompleteResult:int = 0;
        private var timerCompleteData:Object;
        private var timeoutResult:int = 0;

        private var lg:Log;
        private var timerData:Object;

        public function BasicTimerTests()
        {
            lg = new Log('BT');
            tests();
        }

        private function tests():void
        {
            lg.debug(BasicTimer.instance.getTime().toString());
            BasicTimer.instance.setTimeout(50, timeoutTest, {data:50});
            BasicTimer.instance.setInterval(120, intervalTest, {data:120},  5);
            BasicTimer.instance.setTimer(100, timerTest, timerCompleteTest, 5, {data:100}, {data:1000});
            setTimeout(testResultHandler, 2000);
        }

        private function testResultHandler():void
        {
            lg.debug('==> Tests' + Boolean(timeoutResult == 1));
            lg.debug('Timeout handlers ' + Boolean(timeoutResult == 1));
            lg.debug('Interval handlers ' + Boolean(intervalResult == 5));
            lg.debug('Timer handlers ' + Boolean(timerResult == 4));
            lg.debug('Timer data ' + Boolean(timerData.data == 100));
            lg.debug('Timer complete handlers ' + Boolean(timerCompleteResult == 1));
            lg.debug('Timer complete data ' + Boolean(timerCompleteData.data == 1000));

            var t:BasicTest = new BasicTest('BasicTimerTest');
            t.assertSame(timeoutResult, 1, 'timeout result');
            t.assertSame(intervalResult, 5, 'interval result');
            t.assertSame(timerResult, 4, 'timer result');
            t.assertSame(timerData.data, 100, 'timer data');
            t.assertSame(timerCompleteResult,2, 'timer complete result');
            t.assertSame(timerCompleteData.data,  1000, 'timer complete data');
            t.finish();
        }

        private function timerTest(data:Object):void
        {
            lg.debug('timerTest::' + intervalResult);
            timerData = data;
            ObjectUtils.toString(data);
            timerResult++;
        }


        private function timerCompleteTest(data:Object):void
        {
            lg.debug('timerCompleteTest::' + intervalResult);
            timerCompleteData = data;
            ObjectUtils.toString(data);
            timerCompleteResult++;
        }

        private function intervalTest(data:Object):void
        {
            lg.debug('intervalTest::' + intervalResult);
            ObjectUtils.toString(data);
            intervalResult++;
        }

        private function timeoutTest(data:Object):void
        {
            lg.debug('timeoutTest::' + intervalResult);
            ObjectUtils.toString(data);
            timeoutResult++;
        }
    }
}
