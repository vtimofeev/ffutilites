package com.timoff.services.loader.interfaces
{
    import com.timoff.services.loader.data.LoadResourceType;
    import com.timoff.services.loader.managers.LoadSettings;

import flash.utils.ByteArray;

public interface IDataLoader
	{
		function load(url:String, urlDescription:String, dataType:String = LoadResourceType.IMAGE, loadSuccess:Function = null, loadError:Function = null, loadSettings:LoadSettings = null, binaryData:ByteArray = null):void
	}
	
	
	
}
