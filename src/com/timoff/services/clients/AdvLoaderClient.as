package com.timoff.services.clients
{
	import com.timoff.services.loader.events.LoaderProgressEvent;
	import com.timoff.services.loader.interfaces.IAdvLoaderClient;

	public class AdvLoaderClient extends LoaderClient implements IAdvLoaderClient
	{
		private var _progressHandler:Function;
        private var _stopped:Boolean = false;

		public function AdvLoaderClient(successFunction:Function=null, errorFunction:Function=null, progressFunction:Function=null)
		{
			super(successFunction, errorFunction);
		}

		/**
		 * @param event
		 */
		public function progressHandler(event:LoaderProgressEvent):void
		{
			if (Boolean(_progressHandler))
			{
				_progressHandler(event);
			}
		}

		public override function free():void
		{
			super.free();
			_progressHandler=null
		}

    }
}