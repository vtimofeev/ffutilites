/**
 * @author vasily.timofeev@gmail.com
 */
package
{
    import com.timoff.services.test.BasicTest;

    import flash.display.Sprite;
    import flash.net.navigateToURL;

    public class BasicTestTests extends Sprite
    {
        public function BasicTestTests()
        {
            tests();
        }

        private function tests():void
        {
            var bt:BasicTest = new BasicTest('Basic test of BasicTest class');
            var obj:Object = this;
            var contentObj:Object = { id: 1, name: 'testObject', value: 1500};
            var contentArray:Array = [ 1, 2, 3, 4, 10];
            bt.testCase('TRUE CASE')

            bt.assertExist(bt, 'test exists');
            bt.assertNotExist(null, 'tes not exists');
            bt.assertTrue(true, 'test true');
            bt.assertFalse(false, 'test false');
            bt.assertSame(1,1, 'test same');
            bt.assertSame(obj,this, 'test same');
            bt.assertNotSame(true,1, 'test same');
            bt.assertHasProperties(contentObj, ['id','name','value'], 'test props');
            bt.assertHasNoProperties(contentObj, ['ids','names','values'], 'test no props');
            bt.assertHasPropertiesWithValues(contentObj, {id : 1, name:'testObject'}, 'test values of objects');
            bt.assertHasItem(contentObj, 'testObject', 'test data object')
            bt.assertHasNoItem(contentObj, 'helloWorld', 'test data object');
            bt.assertHasItem(contentArray, 1, 'test array');
            bt.assertHasNoItem(contentArray, 9, 'test array');

            bt.finishCase();

            bt.testCase('FALSE CASE');

            bt.assertExist(null, 'test exists');
            bt.assertNotExist(bt, 'test not exists');
            bt.assertTrue(false, 'test true');
            bt.assertFalse(true, 'test false');
            bt.assertSame(1,0, 'test same');
            bt.assertSame(obj,contentObj, 'test same');
            bt.assertNotSame(1,1, 'test same');
            bt.assertHasProperties(contentObj, ['ids','names','values'], 'test props');
            bt.assertHasNoProperties(contentObj, ['id','name','value'], 'test no props');
            bt.assertHasPropertiesWithValues(contentObj, {id : 2, name:'testObject'}, 'test values of objects');
            bt.assertHasItem(contentObj, 'testObject2', 'test data object')
            bt.assertHasNoItem(contentObj, 'testObject', 'test data object');
            bt.assertHasItem(contentArray, 9, 'test array');
            bt.assertHasNoItem(contentArray, 1, 'test array');

            bt.finishCase();
            bt.finish();

        }
    }
}
