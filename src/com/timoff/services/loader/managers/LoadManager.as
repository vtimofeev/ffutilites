package com.timoff.services.loader.managers {

import com.timoff.services.cache.Cache;
import com.timoff.services.clients.*;
import com.timoff.services.loader.data.LoadResourceType;
import com.timoff.services.loader.data.LoaderDataObject;
import com.timoff.services.loader.interfaces.*;
import com.timoff.services.loader.loaders.*;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

public class LoadManager extends EventDispatcher {
    private static var _maxLoaders:uint = 10;
    private static var MAX_ATTEMPTS:uint = 3;
    private static var _instance:LoadManager;

    private var _tasks:Vector.<LoadTask> = new Vector.<LoadTask>();
    private var _dataLoaders:Vector.<DataLoader>;
    private var loadSettings:LoadSettings;

    public static function get instance():LoadManager {
        if (!_instance)
            _instance = new LoadManager;

        return _instance;
    }

    public function LoadManager() {
    }

    public function load(target:ILoaderClient, url:String, loadSettings:LoadSettings):LoaderDataObject {
        var task:LoadTask = new LoadTask(target, [ url ], loadSettings);
        _tasks.push(task);
        refreshTasks();

        return null;
    }

    public function multiload(target:ILoaderClient, urlsArray:Array, loadSettings:LoadSettings):LoaderDataObject {
        var task:LoadTask = new LoadTask(target, urlsArray, loadSettings);
        _tasks.push(task);
        task.refresh();
        refreshTasks();

        return null;
    }

    protected function refreshTasks(event:Event = null):void {
        var loaders:Vector.<DataLoader> = getLoaders();
        if (!loaders) return;
        if (!loaders.length) return;

        for (var i:int = 0; i < loaders.length; i++) {
            var task:LoadTask = getUnloadedTask();
            if (task) {
                var binary:ByteArray = getBinaryCache(task);
                loaders[i].load(task.nextWaitingItem, task.nextWaitingItem, LoadResourceType.AUTO, refreshTasks, refreshTasks, task.loadSettings);
                task.addResultListener(loaders[i]);
            }
        }
        return;
    }

    private function getBinaryCache(task:LoadTask):ByteArray {
        if (task.nextWaitingItem.toLowerCase().indexOf('.swf') < 0) return null;

        var binary:ByteArray = null;
        if (task.loadFromCache)
        {
                const cacheData:LoaderDataObject = Cache.instance.getData(task.nextWaitingItem);
                binary = cacheData ? cacheData.binary : null;
        }
        return binary;
    }

    public function getLoaders():Vector.<DataLoader> {
        var result:Vector.<DataLoader> = new Vector.<DataLoader>();
        var i:int = 0;

        if (!_dataLoaders) {
            _dataLoaders = new Vector.<DataLoader>();
            for (i = 0; i < _maxLoaders; i++) {
                _dataLoaders.push(new DataLoader());
            }

            return _dataLoaders;
        }

        for (i = 0; i < _maxLoaders; i++) {
            if (!(_dataLoaders[i] as DataLoader).busy) {
                result.push(_dataLoaders[i]);
            }
        }
        return result;
    }

    protected function getUnloadedTask():LoadTask {
        for each(var t:LoadTask in _tasks) {
            t.refresh();
            if (t.hasWaitingItems) {
                if (loadingItems().indexOf(t.nextWaitingItem) < 0) {
                    return t;
                }
            }
        }
        return null;
    }

    /**
     *
     * @return array of loading urls
     *
     */
    protected function loadingItems():Vector.<String> {
        var result:Vector.<String> = new Vector.<String>();
        var dl:DataLoader;

        for (var i:int = 0; i < _maxLoaders; i++) {
            dl = _dataLoaders[i];
            if (dl.busy) {
                result.push(dl.loadedUrl);
            }
        }

        return result;
    }


    /**
     * Stop loading, frees loaders resources
     * @todo
     */
    public function free():void {
        return;
    }

    public static function getLoaderClient(successHandler:Function, errorHandler:Function = null, progressHandler:Function = null):ILoaderClient {
        var lc:LoaderClient;

        if (!Boolean(successHandler)) {
            return null;
        }

        if (!Boolean(errorHandler)) {
            errorHandler = successHandler;
        }

        if (!Boolean(progressHandler)) {
            lc = new LoaderClient(successHandler, errorHandler);
        }
        else {
            lc = new AdvLoaderClient(successHandler, errorHandler, progressHandler);
        }

        return lc;
    }
}
}