package com.timoff.utilites {
import com.timoff.services.cache.Cache;

import flash.net.getClassByAlias;
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;
import flash.net.registerClassAlias;

public class ObjectUtils {


    public function ObjectUtils() {
    }

    public static function merge(baseObj:Object, value:Object):Object {
        var propName:String;
        var result:Object = copy(baseObj);

        for (propName in value) {
            result[propName] = value[propName];
        }
        return result;
    }

    public static function castedMerge(baseObj:Object, value:Object, ClassRef:Class, properties:Object):Object {
        var result:Object = new ClassRef();
        var propName:String;

        for (propName in properties) {
            result[propName] = baseObj[propName];
            result[propName] = value[propName];
        }

        return result;
    }


    public static function copy(value:Object):Object {
		
		var buffer:ByteArray = new ByteArray();
        buffer.writeObject(value);
        buffer.position = 0;
        var result:Object = buffer.readObject();
        return result;
    }

    public static function castedCopy(value:Object, ClassRef:Class, properties:Object):Object {

		var result:Object = new ClassRef();
        var propName:String;

        for (propName in properties) {
            result[propName] = value[propName];
        }

        return result;
    }

    public static function toString(value:Object):String {
        var result:String;
        var propName:String;
        result = getQualifiedClassName(value) + " contains ";

        for (propName in value) {
            result += propName + "=" + value[propName] + ", ";
        }

        result += ".";
        return result;
    }
}
}