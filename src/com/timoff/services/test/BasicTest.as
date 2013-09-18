/**
 * @author vasily.timofeev@gmail.com
 */
package com.timoff.services.test
{
    import flash.utils.Dictionary;

    public class BasicTest
    {
        private static const DEFAULT_CASE_NAME:String = 'default';

        public const data:Object = [];

        private var enableTrace:Boolean = true;

        private var name:String;
        private var caseName:String = DEFAULT_CASE_NAME;

        public var successes:int = 0;
        public var errors:int = 0;

        private var _isFinished:Boolean = false;

        public function BasicTest(name:String, enableTrace:Boolean = true)
        {
            this.name = name;
            this.enableTrace = enableTrace;
        }

        public function testCase(name:String):void
        {
            caseName = name;
        }

        public function finishCase():Boolean
        {
            const caseArray:Array = data[caseName]?data[caseName]:data[caseName]=[];
            var caseSuccesses:int = 0;
            var caseErrors:int = 0;

            for each(var itemArray:Array in caseArray)
            {
                itemArray[1]?caseSuccesses++:caseErrors++;
            }

            if (this.enableTrace) trace('Finish case ' + caseName + '. Errors ' + caseErrors + " of " + (caseSuccesses + caseErrors));

            caseName = DEFAULT_CASE_NAME;
            return caseErrors == 0;
        }

        public function assertExist(value:*, message:String):Boolean
        {
            const name:String = 'assertExist';
            const result:Boolean = value ? true : false;
            addResult(result, name, message, value);
            return result;
        }

        public function assertNotExist(value:*, message:String):Boolean
        {
            const name:String = 'assertNotExist';
            const result:Boolean = !value ? true : false;
            addResult(result, name, message, value);
            return result;
        }

        public function assertTrue(value:Boolean, message:String):Boolean
        {
            const name:String = 'assertTrue';
            const result:Boolean = value == true;
            addResult(result, name, message, value);
            return result;
        }

        public function assertFalse(value:Boolean, message:String):Boolean
        {
            const name:String = 'assertFalse';
            const result:Boolean = value == false;
            addResult(result, name, message, value);
            return result;
        }

        public function assertSame(value:*, waiting:*, message:String):Boolean
        {
            const name:String = 'assertSame';
            const result:Boolean = value === waiting;
            addResult(result, name, message, value, waiting);
            return result;
        }

        public function assertNotSame(value:*, waiting:*, message:String):Boolean
        {
            const name:String = 'assertSame';
            const result:Boolean = value !== waiting;
            addResult(result, message, value, waiting);
            return result;
        }

        public function assertHasItem(dataProvider:Object, item:Object, message:String):Boolean
        {
            const name:String = 'assertHasItem';
            var result:Boolean = false;

            if(dataProvider is Array || dataProvider is Dictionary || dataProvider is Object)
            {
                for each(var providerItem:Object in dataProvider) if(providerItem == item) { result = true; break; }
            }
            addResult(result, name, message, dataProvider, item);
            return result;
        }

        public function assertHasNoItem(dataProvider:Object, item:Object, message:String):Boolean
        {
            const name:String = 'assertHasNoItem';
            var result:Boolean = true;

            if(dataProvider is Array || dataProvider is Dictionary || dataProvider is Object)
            {
                for each(var providerItem:Object in dataProvider) if(providerItem == item) { result = false; break; }
            }

            addResult(result, name, message, dataProvider, item);
            return result;
        }

        public function assertHasProperties(value:Object, propNames:Array, message:String):Boolean
        {
            const name:String = 'assertHasProperties';
            var result:Boolean = true;

            for each(var property:String in propNames)
            {
                if (!(property in value)) { result = false; break; }
            }

            addResult(result, name, message, value, propNames.join(','));
            return result;
        }

        public function assertHasNoProperties(value:Object, propNames:Array, message:String):Boolean
        {
            const name:String = 'assertHasNoProperties';
            var result:Boolean = true;

            for each(var property:String in propNames)
            {
                if ((property in value)) { result = false; break; }
            }

            addResult(result, name, message, value, propNames.join(','));
            return result;
        }

        public function assertHasPropertiesWithValues(value:Object, props:Object, message:String):Boolean
        {
            const name:String = 'assertHasPropertiesWithValues';
            var result:Boolean = true;

            for (var property:String in props)
            {
                if (property in value && value[property] == props[property]) continue;

                result = false;
                break;
            }

            addResult(result, name, message, value, props);
            return result;
        }

        private function addResult(result:Boolean, name:String, message:String, ... values):void
        {
            if(_isFinished) throw new Error('You cant execute new asserts, cause test already finished.');

            const msg:String = String(result ? "Success '" : "Error '") + message + "', " + name + " with params {" + values.join(",") + "}";
            const dataItem:Array = [msg, result, name, message, values];
            const caseArray:Array = data[caseName]?data[caseName]:data[caseName]=[];
            caseArray.push(dataItem);

            result ? successes++ : errors++;

            if (this.enableTrace)
            {
                if (caseArray.length == 1) trace(this.name + ' tests of case ' + caseName);
                trace(msg);
            }
        }

        public function finish():Boolean
        {
            _isFinished = true;
            if (this.enableTrace) trace(getFinishMessage());
            return !hasErrors;
        }

        private function getFinishMessage():String
        {
            return 'FINISH:' + String(hasErrors ? 'FAIL' : 'SUCCESS') + " " + name + ", " + caseName + '. Errors ' + errors + " of " + (successes + errors);
        }

        public function get result():String
        {
            var result:String = '';
            for each(var item:Array in data) result += item[0] + '\n';
            if (_isFinished) result += getFinishMessage();
            return result;
        }

        public function get hasErrors():Boolean
        {
            return errors > 0;
        }

        public function get isFinished():Boolean
        {
            return _isFinished;
        }
    }
}
