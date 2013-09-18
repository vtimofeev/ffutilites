package com.timoff.ql
{
    public class Query
    {
        private static const DP_IS_NULL:String = "Data provider is null";
        private static const DP_IS_EMPTY:String = "Data provider is empty";
        private static const PREDICATE_IS_NULL:String = "Predicate is null";
        private static const DP_RESULT_DONT_SUPPORTED:String = "Data provider result type isn't supported";

        //-----------------------------------------------------------------------------
        // Public methods
        //-----------------------------------------------------------------------------

        public static function where(dataProvider:Object, wherePredicate:Function, from:int = -1, limit:int = -1, vectorResultReference:Object = null) : *
        {
            checkDataProvider(dataProvider);
            checkPredicate(wherePredicate);

            const result:* = getResultDataProvider(dataProvider, vectorResultReference);
            const hasFrom:Boolean = from > 0;
            const hasLength:Boolean = limit > -1;
            const tail:int = limit > -1 ? (from + limit) : (-1);

            var position:int = 0;
            var item:Object = null;
            for each (item in dataProvider)
            {
                if (!item) continue;

                if (wherePredicate(item))
                {
                    if (hasFrom)
                    {
                        if (position >= from)
                        {
                            result.push(item);
                        }
                    }
                    else
                    {
                        result.push(item);
                    }
                    position++;
                }

                if (hasLength && tail == position)
                {
                    break;
                }
            }
            return result;
        }

        public static function select(dataProvider:Object, selectPredicate:Function, from:int = -1, limit:int = -1, vectorResultReference:Object = null) : *
        {
            checkDataProvider(dataProvider);
            checkPredicate(selectPredicate);

            const result:* = getResultDataProvider(dataProvider, vectorResultReference);
            const hasFrom:Boolean = from > 0;
            const hasLimit:Boolean = limit > -1;
            const tail:* = limit > -1 ? (from + limit) : (-1);

            var position:int = 0;
            var item:Object = null;

            for each (item in dataProvider)
            {
                if (!item) continue;

                if (hasFrom)
                {
                    if (position >= from)
                    {
                        result.push(selectPredicate(item));
                    }
                }
                else
                {
                    result.push(selectPredicate(item));
                }

                position++;

                if (hasLimit && tail == position) break;
            }
            return result;
        }

        public static function sort(dataProvider:Object, sortFunction:Function, vectorResultReference:Object = null):*
        {
            checkDataProvider(dataProvider);
            checkPredicate(sortFunction);
            
            const result:* = isSortable(dataProvider) ? (dataProvider) : (getResultDataProvider(dataProvider, vectorResultReference, true));
            result.sort(sortFunction);
            return result;
        }

        public static function advancedQuery(dataProvider:Object, wherePredicate:Function, selectPredicate:Function, groupByPerdicate:Function, sortFunction:Function, from:int = -1, limit:int = -1,  vectorResultReference:Object = null) : *
        {
            var result:* = where(dataProvider, wherePredicate, from, limit);
            if (selectPredicate)
            {
                result = select(result, selectPredicate, 0, -1, vectorResultReference);
            }
            if (groupByPerdicate)
            {
                result = groupBy(result, groupByPerdicate);
            }
            if (sortFunction)
            {
                result = sort(result, sortFunction, null);
            }
            return result;
        }

        public static function innerJoin(outProvider:Object, innerProvider:Object, joinPerdicate:Function, mergePredicate:Function, vectorReference:Object = null) : *
        {
            checkDataProvider(outProvider);
            checkDataProvider(innerProvider);
            checkPredicate(joinPerdicate);
            checkPredicate(mergePredicate);

            var result:* = getResultDataProvider(outProvider, vectorReference);
            var outerItem:Object = null;
            var innerItem:Object = null;

            for each (outerItem in outProvider)
            {
                for each (innerItem in innerProvider)
                {
                    if (joinPerdicate(outerItem,innerItem))
                    {
                        result.push(mergePredicate(outerItem,innerItem));
                    }
                }
            }
            return result;
        }

        public static function groupBy(dataProvider:Object, groupByPredicate:Function ) : *
        {
            checkDataProvider(dataProvider);
            checkPredicate(groupByPredicate);

            const result:* = {};

            var groupName:* = undefined;
            var group:Array = null;
            var item:Object = null;

            for each (item in dataProvider)
            {
                if (!item)
                {
                    continue;
                }

                groupName = groupByPredicate(item);
                group = result[groupName] ? result[groupName] : result[groupName] = [];
                group.push(item);
            }
            return result;
        }

        /**
         * Gets result by a query string
         *
         * @param dataProvider Array, Vector, Object, Dictionary or any iterable data provider.
         * @param query String of a query
         * @param args Parameters for a query
         * @param vectorReference Reference to result provider ( Vector<T> )
         * @param extSelectPredicate Select predicate contains extended functional
         * @return
         */
        public static function query(dataProvider:Object, query:String, args:Array = null, vectorReference:Object = null, extSelectPredicate:Function = null):*
        {
            return QueryString.query(dataProvider, query, args, vectorReference, extSelectPredicate);
        }

        //-----------------------------------------------------------------------------
        // Utilites methods
        //-----------------------------------------------------------------------------

        private static function isSortable(dataProvider:Object) : Boolean
        {
            return dataProvider is Vector || dataProvider is Array ? true : false;
        }

        public static function getResultDataProvider(dataProvider:Object, classRefence:Object = null, copy:Boolean = false):*
        {
            const result:* = classRefence ? (new (classRefence as Class)()) : ([]);
            if (!result is Vector || !result is Array) throw new Error(DP_RESULT_DONT_SUPPORTED);

            if (copy)
            {
                var item:* = undefined;
                for each (item in dataProvider)
                {
                    result.push(item);
                }
            }
            return result;
        }

        private static function checkDataProvider(dataProvider:Object) : void
        {
            if (!dataProvider)
            {
                throw new Error(DP_IS_NULL);
            }
            return;
        }

        private static function checkPredicate(perdicate:Function) : void
        {
            if (!perdicate)
            {
                throw new Error(PREDICATE_IS_NULL);
            }
            return;
        }
    }
}
