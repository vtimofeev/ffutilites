package com.timoff.services.loader.events
{
	import flash.events.Event;
	
	public class LoaderProgressEvent extends Event 
	{
		/**
		 * double, from 0 to 1 
		 */
		public var progress:Number;
		
		public function LoaderProgressEvent(  progress:Number , bubbles:Boolean = false , cancelable:Boolean = false )
		{
			super ( LoaderEvent.EVENT_PROGRESS , bubbles , cancelable );
			this.progress = progress;
		}
		
		override public function clone():Event 
		{
			return new LoaderProgressEvent ( progress ,  bubbles , cancelable ) as Event;  
		}
	}
}