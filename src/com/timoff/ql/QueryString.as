package com.timoff.ql
{
    import com.timoff.ql.data.QueryExpressionDataObject;
    import com.timoff.ql.data.TypedAndArray;

    public class QueryString
    {
        private static var treeCache:Object = {};

        public static function query(dataProvider:Object, query:String, args:Array = null, vectorReference:Object = null, extSelectPredicate:Function = null):*
        {
            const queryLower:String = query.toLowerCase();

            const indexSelect:int = queryLower.indexOf('select');
            const indexWhere:int = queryLower.indexOf('where');
            const indexOrder:int = queryLower.indexOf('order by');
            const indexLimit:int = queryLower.indexOf('limit');
            const lastChar:int = queryLower.length;

            const selectContent:String = indexSelect > -1 ? getPartString(query, indexSelect + 6, [indexWhere,indexOrder,indexLimit,lastChar]).replace(/\s/g, '') : null;
            const whereContent:String = indexWhere > -1 ? getPartString(query, indexWhere + 5, [indexOrder,indexLimit,lastChar]) : null;
            const orderContent:String = indexOrder > -1 ? getPartString(query, indexOrder + 8, [indexLimit,lastChar]) : null;
            const limitContent:String = indexLimit > -1 ? getPartString(query, indexLimit + 5, [lastChar]) : null;

            const resultLimit:Array = limitContent ? limitContent.split(',') : [0];
            const limitFrom:int = int(resultLimit[0]);
            const limitLength:int = resultLimit.length > 1 ? int(resultLimit[1]) : -1;
            const limitTo:int = limitFrom + limitLength;

            const resultOrder:Array = orderContent ? orderContent.split(',') : null;

            const resultWhereExpressionTree:Array = whereContent ? query in treeCache ? treeCache[query] : whereQuery(whereContent) : null;
            addToCache(query, resultWhereExpressionTree);

            if (args && args.length)
            {
                const restData:Object = parseRest(args);
                updateTree(resultWhereExpressionTree, restData);
            }

            const selectResult:Array = selectContent && selectContent != '*' ? selectContent.split(',') : null;

            var preResult:* = [];
            const dpLength:int = dataProvider.length;

            var position:int = 0;
            for (var i:int = 0; i < dpLength; i++)
            {
                var item:Object = dataProvider[i];
                if (checkTree(item, resultWhereExpressionTree))
                {
                    if (position >= limitFrom) preResult.push(item);

                    position++;
                    if (limitLength > -1 && position == limitTo) break;
                }
            }

            const resLength:int = preResult.length;

            if (resultOrder) sortProvider(preResult, resultOrder);

            if (vectorReference || selectResult || extSelectPredicate)
            {


                const postResult:* = Query.getResultDataProvider(dataProvider, vectorReference);

                if (selectResult || extSelectPredicate)
                {
                    const hasExtSelectPredicate:Boolean = extSelectPredicate;
                    for (var i:int = 0; i < resLength; i++)
                    {
                        postResult.push((hasExtSelectPredicate ? extSelectPredicate(preResult[i]) : selectPredicate(preResult[i], selectResult)));
                    }
                }
                else
                {
                    for (var i:int = 0; i < resLength; i++)
                    {
                        postResult.push(preResult[i]);
                    }
                }

                return postResult;
            }
            else
                return preResult;
        }

        private static function sortProvider(dataProvider:Object, orders:Array):*
        {
            if (!dataProvider || !dataProvider.length) throw new Error('Cant sort data provider ' + dataProvider);

            const firstItem:Object = dataProvider[0];
            const sortOnFields = [];
            const sortOnOptions = [];

            for each(var order:String in orders)
            {
                order = trim(order);
                var orderParts:Array = order.split(' ');
                var direction:int = 0;
                var type:int = 0;
                var name:String = order;

                if (orderParts.length == 2)
                {
                    if (orderParts[1].toLowerCase() == 'desc') direction = 1;
                    name = orderParts[0];
                }

                if (firstItem[name] is Number || firstItem[name] is Boolean) type = 1;

                sortOnFields.push(name);
                sortOnOptions.push(direction && type ? Array.DESCENDING | Array.NUMERIC : direction ? Array.DESCENDING : type ? Array.NUMERIC : 0);
            }

            if (dataProvider is Array)
            {
                dataProvider.sortOn(sortOnFields, sortOnOptions);
            }
            else if (dataProvider is Vector)
            {
                throw new Error('The vector temporary not supported');
            }
            else
                throw new Error('The sort collection is incorrect type:' + dataProvider);
        }

        private static function updateTree(whereExpressionTree:Object, restData:Object):void
        {
            if (whereExpressionTree is QueryExpressionDataObject)
            {
                whereExpressionTree.updateExternal(restData)
            }
            else
            {
                // whereExp is Array or TypedAndArray
                for each(var expChild in whereExpressionTree) updateTree(expChild, restData)
            }
        }

        private static function parseRest(args:Array):Object
        {
            if (!args || !args.length) return [];

            var result:Object = {};
            var i:int = 1;

            for each(var item:Object in args)
            {
                result['$' + i++] = item;
            }

            return result;
        }

        private static function selectPredicate(item:Object, selectResult:Array):Object
        {
            const result:Object = {};
            var prop:String;
            for each(prop in selectResult)
            {
                result[prop] = item[prop];
            }
            return result;
        }

        private static function checkTree(item:Object, whereExpressionTree:Object):Boolean
        {
            var result:Boolean = false;

            if (whereExpressionTree is QueryExpressionDataObject)
            {
                result = whereExpressionTree.predicate(whereExpressionTree.value, item[whereExpressionTree.name]);
            }
            else if (whereExpressionTree is TypedAndArray)
            {
                // andArray
                for each(var expChild in whereExpressionTree)
                {
                    if (expChild is QueryExpressionDataObject)
                    {
                        result = expChild.predicate(expChild.value, item[expChild.name]);
                        //trace(expChild.name + " :: ", expChild.value, item[expChild.name], result);
                    }
                    else
                    {
                        result = checkTree(item, expChild);
                    }
                    if (!result) break;
                }
            }
            else
            {
                // array
                for each(var expChild in whereExpressionTree)
                {
                    result = checkTree(item, expChild);
                    if (result) break;
                }
            }

            return result;
        }

        private static function addToCache(query:String, resultWhereExpressionTree:Array):void
        {
            if (query.indexOf('$1')) treeCache[query] = resultWhereExpressionTree;
        }

        private static function getPartString(string:String, startIndex:int, indexesEnd:Array):String
        {
            const len:int = indexesEnd.length;
            var indexEnd:int;
            for (var i:int = 0; i < len; i++)
            {
                indexEnd = indexesEnd[i];
                if (indexEnd > 0) return string.substring(startIndex, indexEnd);
            }
            return null;
        }

        public static function whereQuery(where:String):*
        {
            const parsedResult:Object = parseBackets(where);
            const parsedString:String = parsedResult.result;
            const parsedData:Object = parsedResult.resultData;

            const expressionsTree = [];
            parseFunctionTree(expressionsTree, parsedString, parsedData);

            return expressionsTree;
        }

        private static function parseFunctionTree(tree:Array, string:String, data:Object):void
        {
            const hasOrMatches:Boolean = string.indexOf('||') >= 0;
            const hasAndMatches:Boolean = string.indexOf('&&') >= 0;
            const hasKey:Boolean = string.indexOf('$$') >= 0;
            var orMatches:Array;
            var andMatches:Array;

            if (hasOrMatches)
            {
                orMatches = string.split('||');
                for each(var match:String in orMatches) parseFunctionTree(tree, match, data);
            }
            else if (hasAndMatches)
            {
                andMatches = string.split('&&');
                var andArray:Array = new TypedAndArray();
                tree.push(andArray);
                for each(var match:String in andMatches) parseFunctionTree(andArray, match, data);
            }
            else if (hasKey)
            {
                const key:String = string.substr(string.indexOf('$$'), 3);
                if (tree is TypedAndArray)
                {
                    var orTree:Array = [];
                    tree.push(orTree);
                    tree = orTree;
                }
                parseFunctionTree(tree, string.replace(key, data[key]), data);
            }
            else
            {
                tree.push(SimplePredicate.parseExpression(string));
            }
        }

        private static function parseBackets(where:String):Object
        {
            const expression:RegExp = /\([^(^).]*\)/;
            var result:String = where;
            var matches:Array;
            var matchesData:Object = {};
            var i:int = 0;

            while (matches = expression.exec(result))
            {
                const key:String = '$$' + i;
                matchesData[key] = String(matches[0]).replace(/[\(\)]?/g, '');
                result = result.replace(matches[0], key);
                i++;
            }
            return { result: result, resultData:matchesData };
        }

        private static function trim(value:String):String
        {
            return value ? value.replace(/^\s+|\s+$/gs, '') : value;
        }
    }
}


