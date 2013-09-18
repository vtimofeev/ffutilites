package com.timoff.services.loader.events
{
import com.timoff.services.loader.data.LoaderDataObject;

import flash.events.Event;

public class LoaderEvent extends Event
	{
		public static const EVENT_COMPLETE:String="complete";
		public static const EVENT_ERROR:String="error";
		public static const EVENT_PROGRESS:String="progress";

		public var data:LoaderDataObject;
		public var result:Array=[];

		public function LoaderEvent(type:String, data:LoaderDataObject=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data=data;
		}

		public function getContentByUrl(url:String):Object
		{
			if (result.length == 0 || !url || url == '')
				return null;

			for each (var le:Event in result)
			{
				if (le is LoaderEvent)
				{
					if ((le as LoaderEvent).data.url == url)
					{
						return (le as LoaderEvent).data.content;
					}
				}
				else if (le is LoaderErrorEvent)
				{
					if ((le as LoaderErrorEvent).data.url == url)
					{
						return (le as LoaderErrorEvent).data.content;
					}
				}
			}
			return null;
		}

        public function get firstResult():LoaderDataObject
        {
			if (result.length == 0)
                return null;
            else 
                return (result[0] as LoaderEvent).data;
        }

		override public function clone():Event
		{
			return new LoaderEvent(type, data, bubbles, cancelable) as Event;
		}
	}
}
