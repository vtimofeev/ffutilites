/**
 * @author vasily.timofeev@gmail.com
 */
package com.timoff.ql
{
    import com.timoff.ql.data.QueryExpressionDataObject;

    public class SimplePredicate
    {
        public static function parseExpression(match:String):Object
        {
            const matchType:int = match.indexOf('\'') > -1 || match.indexOf('"') > -1 ? 1 : 0;
            match = match.replace(/\s/g, '');

            var parts:Array = [];
            var resultPredicate:Function;
            var resultValue:*;

            if (match.indexOf('<=') > 0)
            {
                parts = match.split('<=');
                resultPredicate = matchType?strLessOrEqual:numLessOrEqual;
            }
            else if (match.indexOf('>=') > 0)
            {
                parts = match.split('>=');
                resultPredicate = matchType?strMoreOrEqual:numMoreOrEqual;
            }
            else if (match.indexOf('>') > 0)
            {
                parts = match.split('>');
                resultPredicate = matchType?strMore:numMore;
            }
            else if (match.indexOf('<') > 0)
            {
                parts = match.split('<');
                resultPredicate = matchType?strLess:numLess;
            }
            else if (match.indexOf('!=') > 0)
            {
                parts = match.split('!=');
                resultPredicate = matchType?strNotEqual:numNotEqual;
            }
            else if (match.indexOf('=') > 0)
            {
                parts = match.split('=');
                resultPredicate = matchType?strEqual:numEqual;
            }
            else
            {
                throw new Error('Unknown expression in : ' + match)
            }

            if(matchType == 0)
                resultValue = parts[1] == 'true' ? 1 : parts[1] == 'false' ? 0 : Number(parts[1]);
            else
                resultValue = String(parts[1]).replace(/[\'\"]?/g, '');

            return new QueryExpressionDataObject(resultPredicate, parts[0], resultValue, matchType?resultValue:parts[1]);
        }

        public static function numEqual(param:*, value:*):Boolean
        {
            return param == value;
        }

        public static function numNotEqual(param:*, value:*):Boolean
        {
            return param != value;
        }

        public static function numMore(param:*, value:*):Boolean
        {
            return value > param;
        }

        public static function numMoreOrEqual(param:*, value:*):Boolean
        {
            return value >= param;
        }

        public static function numLess(param:*, value:*):Boolean
        {
            return value < param;
        }

        public static function numLessOrEqual(param:*, value:*):Boolean
        {
            return value <= param;
        }

        public static function strEqual(param:*, value:*):Boolean
        {
            const uniPos:int = param.indexOf("*");
            if (uniPos < 0) return value == param;

            const searchPart:String = param.replace("*", "");

            if (uniPos == 0)
            {
                return value.lastIndexOf(searchPart) == (value.length - searchPart.length - 1);
            }
            else if (uniPos == (param.length - 1))
            {
                return value.indexOf(searchPart) == 0;
            }
            else
                throw new Error('Unknown position of the unificator.');
        }

        public static function strNotEqual(param:*, value:*):Boolean
        {
            return param != value;
        }

        public static function strMore(param:*, value:*):Boolean
        {
            return value.length > param.length;
        }

        public static function strMoreOrEqual(param:*, value:*):Boolean
        {
            return value.length >= param.length;
        }

        public static function strLess(param:*, value:*):Boolean
        {
            return value.length < param.length;
        }

        public static function strLessOrEqual(param:*, value:*):Boolean
        {
            return value.length <= param.length;
        }
    }
}
