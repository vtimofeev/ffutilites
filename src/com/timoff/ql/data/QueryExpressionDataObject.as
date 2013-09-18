/**
 * @author vasily.timofeev@gmail.com
 */
package com.timoff.ql.data
{
    public class QueryExpressionDataObject
    {
        public var predicate:Function;
        public var name:String;
        public var value:*;
        public var externalValue:String;

        public function QueryExpressionDataObject(predicate:Function, name:String, value:*, externalValue:String = null)
        {
            if(value == undefined || value == null || !name || !predicate) throw new Error('Incorrect QueryExpressionDataObject constructor data');

            this.predicate = predicate;
            this.name = name;
            this.value = value;
            this.externalValue = externalValue is String && externalValue.indexOf('$') == 0 ? externalValue : null;
        }

        public function updateExternal(data:Object)
        {
            if (externalValue && externalValue in data) value = data[externalValue];
        }
    }
}
