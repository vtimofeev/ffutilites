package com.timoff.services.cache {
import com.timoff.services.loader.data.LoaderDataObject;

import flash.net.registerClassAlias;

import flash.utils.Dictionary;
import flash.utils.Timer;

import spark.globalization.supportClasses.GlobalizationBase;

/*
 Cache stores loaded data with url links.

 Хранит загруженные данные, в частности ссылки loader.content / urlLoader.data
 сохраняя url - content связи.
 Используется LoadManager или любым LoaderDataObject генератором.
 */
public class Cache {
    private static var _instance:Cache;
    private var _cache:Dictionary = new Dictionary(true);
    private var _orders:Array = [];
    private var _bytes:int = 0;
    private var _maxSizeBytes:int = 0;
    private var _gcTimer:Timer;

    public function Cache() {
    }

    /**
     * Adds data to the cache, calculate summary bytes length.
     *
     * Добавляет даные в кэш.
     *
     * @param value
     *
     */
    public function setData(value:LoaderDataObject):void {
        if (!value.content) return;

        if (_cache[value.url]) return;

        if (_maxSizeBytes && _maxSizeBytes < _bytes)
        {
            clean();
        }

        _cache[value.url] = value;
        _orders.push(value.url);

        _bytes += value.bytes;

        return;
    }

    private function clean():void {
        for each(var url:String in _orders)
        {
            var lo:LoaderDataObject = _cache[url];
            if(lo)
            {
                _bytes -= lo.bytes;

                lo.content = null;
                if(lo.binary)
                {
                    lo.binary.clear()
                }

                lo.binary = null;
                lo.bytes = 0;

                _cache[url] = null;

                if (_maxSizeBytes > _bytes) return;
            }
        }
        return;
    }

    public function get urls():Array
    {
        const urls:Array = [];
        for each(var lo:LoaderDataObject in _cache)
        {
            urls.push(lo.url);
        }
        return urls;
    }



    /**
     * Get loaded content by url.
     *
     * Получает ссылку на загруженный контент по урл.
     *
     * @param url
     * @return
     */
    public function getContent(url:String):* {
        if (!_cache[url]) {
            return null;
        }

        var content:* = _cache[url].content;
        (_cache[url] as LoaderDataObject).requestCount++;
        return content;
    }

    /**
     * Gets LoaderDataObject by url.
     *
     * Получает loaderDataObject по урл.
     *
     * @param url
     * @return
     */
    public function getData(url:String):LoaderDataObject {
        if (!_cache[url]) return null;
        (_cache[url] as LoaderDataObject).requestCount++;
        return _cache[url];
    }

    public function get maxSizeBytes():int
    {
        return _maxSizeBytes;
    }

    public function set maxSizeBytes(value:int):void
    {
        _maxSizeBytes = value;
    }

    public function set maxSizeMBytes(value:int):void
    {
        _maxSizeBytes = value*1024*1024;
    }

    public function get bytes():int
    {
        return _bytes;
    }

    //--------------------------------------------------------
    // Static
    //--------------------------------------------------------

    public static function get instance():Cache {
        if (!_instance) _instance = new Cache();

        return _instance;
    }

}
}