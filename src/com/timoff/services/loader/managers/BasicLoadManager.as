package com.timoff.services.loader.managers
{
import com.timoff.services.clients.AdvLoaderClient;
import com.timoff.services.loader.interfaces.ILoaderClient;

public class BasicLoadManager
{

    public function BasicLoadManager()
    {
        super();
    }

    public static function load(objects:Object, successHandler:Function, errorHandler:Function, progressHandler:Function, settings:LoadSettings = null):ILoaderClient
    {
        settings = settings ? settings : new LoadSettings(null);
        var client:ILoaderClient = LoadManager.getLoaderClient(successHandler, errorHandler, progressHandler);

        if (objects is Array)
        {
            LoadManager.instance.multiload(client, objects as Array, settings);
        }
        else
        {
            LoadManager.instance.load(client, objects as String, settings);
        }
        return client;
    }

    /*depricated*/
    /*
    public static function contextLoad(objects:Object, successHandler:Function, errorHandler:Function, settings:LoadSettings = null):void
    {
        settings = settings ? settings : new LoadSettings(null);

        if (objects is Array)
        {
            LoadManager.instance.multiload(LoadManager.getLoaderClient(successHandler, errorHandler), objects as Array, settings);
        }
        else
        {
            LoadManager.instance.load(LoadManager.getLoaderClient(successHandler, errorHandler), objects as String, settings);
        }
    }
    */

}
}