package com.timoff.services.loader.loaders
{
import com.timoff.services.loader.data.*;
import com.timoff.services.loader.events.LoaderErrorEvent;
import com.timoff.services.loader.events.LoaderEvent;
import com.timoff.services.loader.interfaces.*;
import com.timoff.services.loader.managers.LoadSettings;
import com.timoff.services.time.BasicTimer;

import flash.display.Loader;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.Capabilities;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.clearInterval;
import flash.utils.setInterval;

public class DataLoader extends EventDispatcher implements IDataLoader
{
    private static const IMAGES_EXT:Array = ["png", "jpg", "jpeg", "gif"];
    private static const SWF_EXT:Array = ["swf"];
    private static const SOUNDS_EXT:Array = ["mp3", "wav"];

    private static var loadStartTimout:int = 15000;
    //private static var loadTimout:int = 100000;

    private var urlLoader:URLLoader;
    private var dataLoader:Loader;
    private var soundLoader:Sound;

    private var urlRequest:URLRequest;

    private var url:String;
    private var urlDescription:String;
    private var attempt:Number = 0;
    private var maxAttempts:Number = 1;
    private var resourceType:String = LoadResourceType.IMAGE;

    private var loadSuccessFunc:Function;
    private var loadErrorFunc:Function;

    private var loadSuccessNotify:String;
    private var loadFailNotify:String;
    private var attemptFailNotify:String;

    private var isLoaded:Boolean = false;
    private var isBusy:Boolean = false;

    private var loadTimer:Timer;
    private var startTimer:Timer = new Timer(loadStartTimout);

    private var loadInterval:int = 0;
    private var loadSettings:LoadSettings;
    private var errors:Array = [];
    //private var useContext:Boolean = false;
    private var _binaryData:Object = null;
    private var loadStartTime:Number = 0;

    public function DataLoader()
    {
        startTimer.addEventListener(TimerEvent.TIMER, internalErrorHandler, false, 0, true);
    }

    /**
     * Default Load Method
     *
     * @param url
     * @param urlDescription
     * @param dataType type of data ( text or binary - image or swf )
     * @param loadSuccess function called on load complete
     * @param loadError function called on load error ( and has no attempts )
     * @param maxAttempts count attempt
     */
    public function load(url:String, urlDescription:String, dataType:String = LoadResourceType.IMAGE, loadSuccess:Function = null, loadError:Function = null, loadSettings:LoadSettings = null, binaryData:ByteArray = null):void
    {
        free();


        isBusy = true;

        this.url = url;
        this.urlDescription = urlDescription;
        this._binaryData = binaryData;

        this.loadSuccessFunc = loadSuccess;
        this.loadErrorFunc = loadError;

        this.loadSuccessNotify = loadSuccessNotify;
        this.loadFailNotify = loadFailNotify;
        this.attemptFailNotify = attemptFailNotify;
        this.resourceType = checkDataType(dataType, url);
        this.loadSettings = loadSettings;
        this.loadStartTime = BasicTimer.instance.getTightTime();

        // Sound.load() method causes an error if we call more one times a load method
        (resourceType == LoadResourceType.SOUND) ? this.maxAttempts = 1 : this.maxAttempts = loadSettings.attempts;

        init();
        loadInterval = setInterval(reload, 10);
    }

    private function reload():void
    {
        clearInterval(loadInterval);

        if (loader is Loader)
        {
            loader.load(new URLRequest(url), context);
        }
        else if (loader is Sound && attempt == 0)
        {
            loader.load(new URLRequest(url));
        }
        else if (loader is Sound)
        {
            internalErrorHandler(new ErrorEvent("Sound instance can't load the url twice"));
        }
        else
        {
            if (!_binaryData)
            {
                loader.load(new URLRequest(url));
            }
            else
            {
                loadBytes();
            }
        }

        startTimer.start();
    }

    private function loadBytes():void
    {
        if (resourceType == LoadResourceType.IMAGE || resourceType == LoadResourceType.SWF)
            dataLoader.loadBytes(_binaryData as ByteArray);
        else
            completeHandler(null);

        // todo Sound

        /*
        dataLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
        dataLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, internalErrorHandler, false, 0, true);
        dataLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
        dataLoader.loadBytes(_binaryData as ByteArray);
        */
    }

    private function init():void
    {
        try
        {
            if (loadSettings.loadMode == LoadMode.BINARY)
            {
                if (!urlLoader) urlLoader = new URLLoader();
                urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
                urlLoader.addEventListener(Event.COMPLETE, preCompleteHandler, false, 0, true);
                urlLoader.addEventListener(IOErrorEvent.IO_ERROR, internalErrorHandler);
                urlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
                urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, internalErrorHandler, false, 0, true);
            }

            switch (resourceType)
            {
                case LoadResourceType.SWF:
                case LoadResourceType.IMAGE:
                    if (!dataLoader) dataLoader = new Loader();
                    dataLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
                    dataLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, internalErrorHandler, false, 0, true);
                    dataLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
                    break;

                case LoadResourceType.SOUND:
                    // can't use a Sound instance twice
                    // always create new object to store in library
                    soundLoader = new Sound();
                    soundLoader.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
                    soundLoader.addEventListener(IOErrorEvent.IO_ERROR, internalErrorHandler, false, 0, true);
                    soundLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
                    soundLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, internalErrorHandler, false, 0, true);
                    break;

                default:
                    if (loadSettings.loadMode == LoadMode.BINARY) return;
                    if (!urlLoader) urlLoader = new URLLoader();

                    urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
                    urlLoader.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
                    urlLoader.addEventListener(IOErrorEvent.IO_ERROR, internalErrorHandler);
                    urlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
                    urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, internalErrorHandler, false, 0, true);
                    break;
            }
        }
        catch (error:Error)
        {
        }

        return;
    }

    private function checkDataType(dataType:String, url:String):String
    {
        var ext:String = "";

        if (dataType == LoadResourceType.AUTO)
        {
            if (url.indexOf("?") > -1)
            {
                url = url.substr(0, url.indexOf("?"));
            }

            if (url.lastIndexOf(".") > -1)
            {
                ext = url.substr(url.lastIndexOf(".") + 1).toLowerCase();
            }

            if (IMAGES_EXT.indexOf(ext) > -1)
            {
                return LoadResourceType.IMAGE;
            }
            else if (SWF_EXT.indexOf(ext) > -1)
            {
                return LoadResourceType.SWF;
            }
            else if (SOUNDS_EXT.indexOf(ext) > -1)
            {
                return LoadResourceType.SOUND;
            }
            else
            {
                return LoadResourceType.TEXT;
            }
        }
        else
            return dataType;
    }

    public function get loader():Object
    {
        if (loadSettings.loadMode == LoadMode.BINARY && resourceType != LoadResourceType.SOUND) return urlLoader;
        
        switch (resourceType)
        {
            case LoadResourceType.SWF:
            case LoadResourceType.IMAGE:
                return dataLoader;
            case LoadResourceType.SOUND:
                return soundLoader;
            default:
                return urlLoader;
        }
    }

    public function get context():LoaderContext
    {
        if (loadSettings.useContext)
        {
            var result:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain);

            if (Capabilities.playerType != "External" && Capabilities.playerType != "StandAlone")
            {
                //result.securityDomain = SecurityDomain.currentDomain;
            }

            result.checkPolicyFile = true;
            return result;
        }
        else
        {
            return null;
        }
    }

    public function get data():Object
    {
        var result:Object;

        switch (resourceType)
        {
            case LoadResourceType.IMAGE:
                result = dataLoader.content;
                break;
            case LoadResourceType.SWF:
                result = dataLoader.content;
                break;
            case LoadResourceType.SOUND:
                result = soundLoader;
                break;
            default:
                result = urlLoader.data;
                break;
        }

        return result;
    }

    public function get loadedUrl():String
    {
        return url;
    }

    public function get busy():Boolean
    {
        return isBusy;
    }

    public function get loadedBytes():Number
    {
        if (loader is Sound)
            return (loader as Sound).bytesLoaded;

        if (loader is Loader)
            return (loader as Loader).contentLoaderInfo.bytesLoaded;

        if (loader is URLLoader)
            return (loader as URLLoader).bytesLoaded;

        return 0;
    }

    public function free():void
    {
        isLoaded = false;
        isBusy = false;
        clearInterval(loadInterval);
        attempt = 0;
        loadStartTime = 0;

        errors = [];

        if (startTimer.running) startTimer.stop();

        if (dataLoader)
        {
            dataLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
            dataLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, internalErrorHandler);
            dataLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);

            dataLoader.unload();
        }

        if (soundLoader)
        {

            soundLoader.removeEventListener(Event.COMPLETE, completeHandler);
            soundLoader.removeEventListener(IOErrorEvent.IO_ERROR, internalErrorHandler);
            soundLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, internalErrorHandler);
            soundLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);

            soundLoader = null;
        }

        if (urlLoader)
        {
            urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, internalErrorHandler);
            urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, internalErrorHandler);
            urlLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
            urlLoader.removeEventListener(Event.COMPLETE, preCompleteHandler);
        }

        return;
    }


    public function stop():void
    {
        if (dataLoader)
        {
           dataLoader.close();
        }

        if (soundLoader)
        {
            soundLoader.close();
        }

        if (urlLoader)
        {
           urlLoader.close();
        }
    }



    ////////////////////////////////////////////////////////////////////////////////////////////
    private function dispatchSimpleEvent(value:String):void
    {
        dispatchEvent(new Event(value));
    }

    private function dispatchLoaderEvent(value:String):void
    {
        var ld:LoaderDataObject = new LoaderDataObject(url, data, _binaryData as ByteArray);
        ld.bytes = loadedBytes;
        ld.time = BasicTimer.instance.getTightTime() - loadStartTime;

        dispatchEvent(new LoaderEvent(value, ld));
        return;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    protected function internalErrorHandler(event:Event):void
    {
        (startTimer.running) ? startTimer.stop() : null;

        errors.push(event);

        (++attempt < maxAttempts) ? reload() : errorHandler(event);
        return;
    }

    protected function progressHandler(event:ProgressEvent):void
    {
        (startTimer.running) ? startTimer.stop() : null;
        dispatchEvent(event);

        return;
    }

    protected function preCompleteHandler(event:Event):void
    {
        (startTimer.running) ? startTimer.stop() : null;

        urlLoader.removeEventListener(Event.COMPLETE, preCompleteHandler);
        urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, internalErrorHandler);
        urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, internalErrorHandler);
        urlLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);

        _binaryData = urlLoader.data;
        loadBytes();
        return;
    }

    [Event(name="complete", type="com.timoff.services.loader.events.LoaderEvent")]
    protected function completeHandler(event:Event):void
    {
        (startTimer.running) ? startTimer.stop() : null;

        isBusy = false;
        dispatchLoaderEvent(LoaderEvent.EVENT_COMPLETE);

        if (Boolean(loadSuccessFunc))
            loadSuccessFunc(event);

        return;
    }

    [Event(name="error", type="com.timoff.services.loader.events.LoaderErrorEvent")]
    protected function errorHandler(event:Event):void
    {
        isBusy = false;
        var le:LoaderErrorEvent = new LoaderErrorEvent(LoaderEvent.EVENT_ERROR);
        le.data = new LoaderDataObject(url, null);
        le.errors = errors;

        dispatchEvent(le);

        if (Boolean(loadErrorFunc))
            loadErrorFunc(event);

        return;
    }
}
}