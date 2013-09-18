package com.timoff.services.loader.events
{
import com.timoff.services.loader.data.LoaderDataObject;

	public class LoaderErrorEvent extends LoaderEvent
	{
		public var errors:Array=[];

		public function LoaderErrorEvent(type:String, data:LoaderDataObject=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, data, bubbles, cancelable)                        
		}
	}
}