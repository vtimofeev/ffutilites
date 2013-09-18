package com.timoff.services.loader.interfaces {
import flash.events.Event;

public interface ILoaderClient {
    function successHandler(event:Event):void;
    function errorHandler(event:Event):void;
    function get stopped():Boolean;
    function stop():void;

}
}