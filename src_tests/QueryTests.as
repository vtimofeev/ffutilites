/**
 * Created by IntelliJ IDEA.
 * User: Vasily
 * Date: 03.02.12
 * Time: 11:46
 * To change this template use File | Settings | File Templates.
 */
package
{
    import com.timoff.ql.Query;
    import com.timoff.services.log.Log;
    import flash.display.Sprite;

    public class QueryTests extends Sprite
    {
        private var longDataProvider:Array;
        private var longLength:int = 100000;

        private var shortDataProvider:Array;
        private var shortLength:int = 100;

        private const charsEn:Array = ['a','b','c','d','e','f','j','h','i','j','q','n','m','g','t','y','u','i','o','p','l','k','z','x','y','c']

        public function QueryTests()
        {
            prepare();
            tests();
        }

        private function prepare():void
        {
            longDataProvider = [];
            shortDataProvider = [];

            for (var i:int = 0; i < longLength ; i++)
            {
                longDataProvider.push({ id : i , name : getRandomItem(charsEn) + getRandomItem(charsEn) + getRandomItem(charsEn) + getRandomItem(charsEn), isHuman: (i%2?true:false) });
            }

            for (i = 0; i < shortLength ; i++)
            {
                shortDataProvider.push({ id : i , name : getRandomItem(charsEn) + getRandomItem(charsEn) + getRandomItem(charsEn) + getRandomItem(charsEn), isHuman: (i%2?true:false) });
            }

            shortDataProvider = longDataProvider;
        }

        private function tests():void
        {
            // var result:Array = Query.where(notTypedDataProvider, Predicate.equal("id" , 1), null, 0, 10 ) as Array;
            // var res:Boolean = Predicate.equal("id" , 2)({id : 3});
            // trace(result.length);

            var lg = new Log('DF');
            var result:Array;
            lg.debug('-------------------- Start tests: String query');

            //testing
            /*

            // testing simple


            lg.debug('==> Test simple query');
            result = Query.stringQuery(shortDataProvider, 'where id > 49');
            lg.debug('Test count: ' + result.length + "," + Boolean(result.length == 50));

            result = Query.stringQuery(shortDataProvider, 'select * where id > 49');
            lg.debug('==> Test select');
            lg.debug('Test count: ' + result.length + ", " + Boolean(result.length == 50));
            lg.debug('Test item: ' + hasProperties(result[0], ['id', 'name', 'isHuman']) );

            lg.debug('==> Test limit');
            result = Query.stringQuery(shortDataProvider, 'select * where id > 0 limit 0,10');
            lg.debug('Test count: ' + result.length + ", " + Boolean(result.length == 10));
            result = Query.stringQuery(shortDataProvider, 'select * where id > 0 limit 10,10');
            lg.debug('Test count: ' + result.length + ", " + Boolean(result.length == 10));

            lg.debug('==> Test order');
            result = Query.stringQuery(shortDataProvider, 'select * where id >= 0 order by id desc');
            lg.debug('Test id: ' + result.length + ", " + Boolean(result[0].id == 99));
            result = Query.stringQuery(shortDataProvider, 'select * where id >= 0 order by id desc limit 0,10');
            lg.debug('Test id: ' + result.length + ", " + Boolean(result[0].id == 9));

            lg.debug('==> Test select item content');
            result = Query.stringQuery(shortDataProvider, 'select id where id > 49');
            lg.debug('Has properties: ' + hasProperties(result[0], ['id']) );
            lg.debug('Has no properties: ' + hasNoProperties(result[0], ['name', 'isHuman']) );

            */
            lg.debug('==> Test where content');
            result = Query.query(shortDataProvider, 'where id > 49 && isHuman = false');
            lg.debug('Result: ' + (result[0].id > 49 && result[0].isHuman == false) );
            result = Query.query(shortDataProvider, 'where id > 49 || isHuman = true');
            lg.debug('Result: ' + (result[0].id < 49  && result[0].isHuman == true) );
            result = Query.query(shortDataProvider, 'where name = "a*" || name = "b*" || name = "c*"');
            lg.debug('Result: ' + result.length);


            lg.debug('-------------------- Start tests: Predicate query');

            lg.debug('==> Test where predicate');
            result = Query.where(shortDataProvider, function(item:Object){return item.id > -1});
            lg.debug('Test count: ' + result.length + "," + Boolean(result.length == 100));
            result = Query.where(shortDataProvider, function(item:Object){return item.id > -1}, 0, 10);
            lg.debug('Test count: ' + result.length + "," + Boolean(result.length == 10));
            result = Query.where(shortDataProvider, function(item:Object){return item.id > 49 && item.isHuman == true}, 0, 10);
            lg.debug('Test item: ' + result.length + "," + Boolean(result[0].id > 49 && result[0].isHuman == true));

            lg.debug('==> Test select predicate');
            result = Query.select(shortDataProvider, function(item:Object){return {id: item.id*100}; }, 0,10);
            lg.debug('Test count: ' + result.length );
            lg.debug('Has properties: ' + hasProperties(result[0], ['id']) );
            lg.debug('Has no properties: ' + hasNoProperties(result[0], ['name', 'isHuman']) );

            lg.debug('==> Test group predicate');
            var resultO = Query.groupBy(shortDataProvider, function(item:Object) {return item.isHuman?'humans':'aliens'} );
            lg.debug('Test count: ' + resultO['humans'].length + ", "+ resultO['aliens'].length + ", " +  Boolean(resultO['humans'] > 0 && resultO['aliens'] > 0) );

            lg.debug('==> Test sort');

            result = Query.sort(shortDataProvider, function(itemA, itemB) { return itemA.name > itemB.name ? -1 : itemA.name == itemB.name ? 0 : 1 ; });
            lg.debug('Result ' + result[0].name + " , " + result[result.length-1].name + " , " + Boolean(result[0].name > result[result.length-1].name) );

            lg.debug('==> Test join');

            result = Query.innerJoin(shortDataProvider, [{id:false, name : 'aliens'},{id:true, name: 'humans'}],
                    function(itemA, itemB) { return itemA.isHuman == itemB.id },
                    function(itemA,itemB) { return { id:itemA.id, type:itemB.name } }
                    );

            lg.debug('Test count: ' + result.length + ", " + Boolean(result.length == 100));

            lg.debug('==> Test advanced query');
            result = Query.advancedQuery(shortDataProvider, function(item) {return item.id > 49}, function(item) { return {id:item.id} }, null, null, 0,10);
            lg.debug('Test count: ' + result.length  + ", " + Boolean(result.length == 10));

            trace("1");
        }

        private function hasProperties(item:Object, hasProperties:Array):Boolean
        {
            for each(var property:String in hasProperties)
            {
                if (!(property in item)) return false;
            }
            return true;
        }

        private function hasNoProperties(item:Object, hasNoProperties:Array):Boolean
        {
            for each(var property:String in hasNoProperties)
            {
                if ((property in item)) return false;
            }
            return true;
        }


        public static function getRandomItem(array:Array):Object
        {
            return array[int(Math.random() * (array.length - 1))];
        }
    }
}
