package com.timoff.services.clients
{
	import flash.events.Event;

	import com.timoff.services.loader.events.LoaderProgressEvent;
	import com.timoff.services.loader.interfaces.ILoaderClient;

	public class LoaderClient implements ILoaderClient
	{
		private var _successHandler:Function;
		private var _errorHandler:Function;
        private var _stopped:Boolean = false;

		public function LoaderClient(successFunction:Function=null, errorFunction:Function=null)
		{
			_successHandler=successFunction;
			_errorHandler=errorFunction;
		}

		/**
		 * Handles on load success result
		 *  
		 * @param event
		 * 
		 */
		public function successHandler(event:Event):void
		{
			if (Boolean(_successHandler))
			{
				_successHandler(event);
			}
		}

		/**
		 * Handles on load fault result
		 *  
		 * @param event
		 * 
		 */
		public function errorHandler(event:Event):void
		{
			if (Boolean(_errorHandler))
			{
				_errorHandler(event);
			}
		}

		public function free():void
		{
			_successHandler=null;
			_errorHandler=null;
		}

        public function get stopped():Boolean {
            return _stopped;
        }

        public function stop():void {
            _stopped = true;
        }
    }
}