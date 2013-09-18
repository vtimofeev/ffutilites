package com.timoff.services.loader.interfaces
{
	import flash.events.Event;
	
	public interface ISuccessListener
	{
		function successHandler ( event:Event ) : void;
		function faultHandler ( event:Event ) : void;
	}
}