/**
 * @Author vtimofeev
 */
package com.timoff.services.time {
public class BasicTimerObject {
    public static const STATE_NONE:int = 0;
    public static const STATE_ACTIVE:int = 1;
    public static const STATE_REMOVED:int = 2;

    private var _delay:int = 0;
    public var nextExecutionTime:int = 0;
    public var executionCounter:Number = 0;
    public var maxExecutionTimers:int = 0;
    public var linkedObject:Object = null;

    public var state:int = 0;

    public var handler:Function;
    public var params:Object;
    public var completeHandler:Function;
    public var completeParams:Object;

    public function BasicTimerObject(delay:int, handler:Function, params:Object = null, maxExecutionTimers:int = 0,  state:int = 0, listener:Object = null) {
        this.delay = delay;
        this.handler = handler;
        this.maxExecutionTimers = maxExecutionTimers;
        this.params = params;
        this.state = state;
        this.linkedObject = listener;
    }

    public function reset():void
    {
        executionCounter = 0;
    }

    public function play():void {
        state = STATE_ACTIVE;

    }

    public function pause():void {
        state = STATE_NONE;
    }

    public function stop():void {
        state = STATE_NONE;
        executionCounter = 0;
    }

    public function remove():void {
        linkedObject = null;
        handler = null;
        params = null;
        completeHandler = null;
        completeParams = null;
        nextExecutionTime = 0;
        state = STATE_REMOVED;
    }

    public function get delay():int {
        return _delay;
    }

    public function set delay(value:int):void {
        _delay = value;
        nextExecutionTime = BasicTimer.instance.getTightTime() + _delay;
    }
}
}
