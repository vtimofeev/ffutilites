/**
 * Author: Vasily Timofeev
 * Web: http://timoff.com
 */
package com.timoff.services.cache {

import com.timoff.services.time.BasicTimer;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

/*
Manages often used instances.
You can store instances of visual or logic classes.
Use addInstance method when you delete instance of any class.
Use getInstance method with className to get unused instance of class.

Use timeInStorage parameter ( in seconds ) to
set max storage time of item in the pool.

Note: before adding instance to the pool you need remove all external links
such eventListeners, links to another display object e,t.c.
*/
public class PoolManager {
    public static const DEFAULT_EXCLUDED:Array = [Shape, Sprite, MovieClip, Bitmap];
    public static var DEFAULT_LIFETIME:int = 300;
    public static var DEFAULT_GC_TIME:int = 120;

    private static var __instance:PoolManager;
    private var _excludedClasses:Array;
    //private var storage:Dictionary;
    private var storage:Object;
    private var gcTimer:Timer;
    private var getCounter:Number = 0;
    private var addCounter:Number = 0;
    private var gcCounter:int = 0;

    public function PoolManager(enableTimer:Boolean = true, excludedClasses:Array = null) {
        _excludedClasses = excludedClasses ? excludedClasses : DEFAULT_EXCLUDED;
        //storage = new Dictionary(false);
        storage = new Object();
        gcTimer = new Timer(DEFAULT_GC_TIME * 1000);
        gcTimer.addEventListener(TimerEvent.TIMER, gcHandler, false, 1, true);
        storage[PoolValueObject.NAME] = [];
    }

    /*
     Sets links to excluded constructors of instances, by
     default it sets excluded instances.
     Note: If you manually sets specific className at addInstance method then checking skips.
     */
    public function set excludedClasses(value:Array):void {
        _excludedClasses = value;
    }

    /*
     Add instance to pool.
     You can set a class name, life time object in seconds.
     */
    public function addInstance(value:Object, className:String = null, timeInStorage:uint = 300):Boolean {
        if (!value) return false;
        const name:String = className ? className : getQualifiedClassName(value);

        if (!className)
        {
            const proto:Class = value.constructor as Class;
            if (proto in _excludedClasses) return false;
        }

        var namedStorage:Array = storage[name];
        if (!namedStorage) namedStorage = storage[name] = [];

        var poolValueObject:PoolValueObject = getInstance(PoolValueObject.NAME) as PoolValueObject;
        if (!poolValueObject) poolValueObject = new PoolValueObject();

        poolValueObject.init(value, timeInStorage, BasicTimer.instance.getTime());
        namedStorage.push(poolValueObject);

        addCounter++;
        return true;
    }

    /*
     Get instance from pool.
     You can get instance from pool use class name or your specific name.
     */
    public function getInstance(name:String):* {

        var namedStorage:Array = storage[name];
        if (!namedStorage) namedStorage = storage[name] = [];

        if (namedStorage.length) {
            const item:PoolValueObject = namedStorage.pop();
            if (name == PoolValueObject.NAME) {
                getCounter++;
                return item;
            }

            const object:Object = item.object;
            {
                item.object = null;
                storage[PoolValueObject.NAME].push(item);
                addCounter++;
            }

            //trace ("Get from pool " + getCounter);
            getCounter++;
            return object;
        }
        else {
            return null;
        }
    }

    /*
     Clean cache by timer and cache lifetime.
     */
    private function gcHandler(event:TimerEvent):void {
        const currentTime:Number = getTimer() / 1000;
        var arrayPoolObjects:Array;
        var item:PoolValueObject;
        var i:int = 0;

        for each(arrayPoolObjects in storage) {
            if (!arrayPoolObjects) continue;
            if (!arrayPoolObjects.length) continue;
            i = 0;
            for each(item in arrayPoolObjects) {
                if ((currentTime - item.creationTime) > item.lifeTime ? item.lifeTime : DEFAULT_LIFETIME) {
                    item = arrayPoolObjects.splice(i, 1);
                    item.free();
                }
                else {
                    i++;
                }
            }
        }

        gcCounter++;
    }

    // -----------------------------------------------------------------
    // Static methods
    // -----------------------------------------------------------------


    public function toString():String {
        return "Add/get: " + addCounter + "/" + getCounter;
    }

    public static function get instance():PoolManager {
        return __instance ? __instance : __instance = new PoolManager();
    }
}
}

/*
 internal class PoolValueObject {
 public static const NAME:String = "com.timoff.services.cache::PoolValueObject";

 public var object:Object;
 public var lifeTime:Number = 0;
 public var creationTime:Number = 0;

 public function PoolValueObject() {
 this.object = object;
 this.lifeTime = lifeTime;
 this.creationTime = creationTime;
 }

 public function init(object:Object, lifeTime:Number, creationTime:Number):void {
 this.object = object;
 this.lifeTime = lifeTime;
 this.creationTime = creationTime;
 }
 public function free():void {
 object = null;
 }
 }
 */


