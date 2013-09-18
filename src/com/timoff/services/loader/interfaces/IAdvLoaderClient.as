package com.timoff.services.loader.interfaces
{
import com.timoff.services.loader.events.LoaderProgressEvent;

public interface IAdvLoaderClient extends ILoaderClient
	{
		function progressHandler ( event:LoaderProgressEvent ) : void;
	}
}