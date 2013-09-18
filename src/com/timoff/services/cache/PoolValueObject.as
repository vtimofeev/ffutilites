/**
 * Author: Vasily Timofeev
 * Web: http://timoff.com
 */
package com.timoff.services.cache {
public class PoolValueObject {
    public static const NAME:String = "com.timoff.services.cache::PoolValueObject";

    public var object:Object;
    public var lifeTime:Number = 0;
    public var creationTime:Number = 0;

    public function PoolValueObject() {
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
}
