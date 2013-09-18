/**
 * @Author vtimofeev
 */
package com.timoff.services.time {

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

/*
 Base timer manager
 It uses one system timer to update all micro timers with delay that sets by DELAY param.
 It must uses small cpu and memory because we have only one system time listener.

 Use:
 setTimeout - to execute handler once
 setInterval - to multiply executing handler function but not more when maxExecutingTimes
 setTimer - to sets multihandlers those catche onTimer event and onComplete event
 removeAllTimersByObject - destroy all timers object is a listener

 Базовый менеджер таймеров,
 Использует один системный таймер обновляющий все миротаймеры с задержкой DELAY.
 Можно устанавливать таймеры используя следующие методы:

 Использование:
 setInterval - таймер выполнящийся определенное количество раз или бесконечно, после чего удаляет себя и все ссылки
 setTimeout - таймер выполняющийся один раз
 setTimer - таймер аналог обычного таймера, имеет 2 основных входных параметра TimerHandler и CompleteHandler
 removeAllTimersByObject - уничтожает все таймеры где слушатель - объект
 */
public class BasicTimer {
    public static const DELAY:int = 20;
    private var timer:Timer;
    private var _systemTime:Number = 0;
    private var basicTimerObjectsVector:Vector.<BasicTimerObject> = new Vector.<BasicTimerObject>();
    private static var __instance:BasicTimer;

    public function BasicTimer() {
        timer = new Timer(DELAY, 0)
        timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 1, true);
        timer.start();
    }

    private function timerHandler(event:TimerEvent):void {
        _systemTime = getTimer();

        var i:int = -1;
        for each (var bto:BasicTimerObject in basicTimerObjectsVector) {
            i++;
            if (bto.state == BasicTimerObject.STATE_NONE) {
                continue;
            }
            else
            if (bto.state == BasicTimerObject.STATE_ACTIVE)
            {
                if (bto.nextExecutionTime <= _systemTime) execute(bto);
            }
            else
            if (bto.state == BasicTimerObject.STATE_REMOVED)
            {
                basicTimerObjectsVector.splice(i, 1);
                i--;
            }

        }
    }

    private function execute(bto:BasicTimerObject):void {
        var completeHandlerWasExecuted:Boolean = false;

        bto.nextExecutionTime = _systemTime + bto.delay;
        bto.executionCounter++;

        const completed:Boolean = bto.maxExecutionTimers && (bto.maxExecutionTimers <= bto.executionCounter);
        if (completed) {
            if (bto.completeHandler) {
                completeHandlerWasExecuted = true;
                if (bto.completeParams)
                    bto.completeHandler(bto.completeParams);
                else
                    bto.completeHandler();
            }
        }

        if (!completeHandlerWasExecuted) {
            if (bto.params)
                bto.handler(bto.params);
            else
                bto.handler();
        }

        if (completed)  bto.remove();
        return;
    }

    private function check(intervalMs:int, handler:Function):void {
        if (!intervalMs || intervalMs < 0) throw new Error("Error: Basic timer incorrect interval " + intervalMs);
        if (!handler) throw new Error("Error: Basic timer incorrect handler of timer " + handler);
    }


    //-------------------------------------------------------------------------------------------
    // Public methods
    //-------------------------------------------------------------------------------------------

    /**
     * Fast getTime method
     * @return
     */
    public function getTime():Number {
        return _systemTime;
    }

    /**
     * Slow and tight getTime method
     * @return
     */
    public function getTightTime():Number {
        return _systemTime = getTimer();
    }

    /**
     * Sets timer and return timer object.
     *
     * @param delayMs - delay
     * @param timerHandler - default handler
     * @param completeHandler - complete handler, it's not required
     * @param maxExecutionTimes - 0 - ,
     * @param listener - object, it's not required
     * @param params - simple object/object with params to pass timerHandler, it's not required
     * @param completeParams - simple object/object with params to pass timerHandler, it's not required
     * @return instance of BasicTimerObject
     */
    public function setTimer(delayMs:int, timerHandler:Function, completeHandler:Function = null, maxExecutionTimes:int = 0, params:Object = null, completeParams:Object = null, listener:Object = null):BasicTimerObject {
        const bto:BasicTimerObject = setInterval(delayMs, timerHandler, params, maxExecutionTimes, listener);
        bto.state = 0;
        if (completeHandler) {
            bto.completeHandler = completeHandler;
            bto.completeParams = completeParams ? completeParams : params;
        }

        return bto;
    }

    /**
     * Sets timeout, execute once
     *
     * @param intervalMs - delay between execution
     * @param handler - default handle function
     * @param params - default params
     * @param listener - object that related with handler
     * @return instance of BasicTimerObject
     */
    public function setTimeout(intervalMs:int, handler:Function, params:Object = null, listener:Object = null):BasicTimerObject {
        return setInterval(intervalMs, handler, params, 1, listener);
    }

    /**
     * Sets interval, timer that multiply executing
     *
     * @param intervalMs - delay between execution
     * @param handler - default handle function
     * @param params - default params
     * @param maxExecutionTimes - max times of executing
     * @param listener - object that related with handler function
     * @return instance of BasicTimerObject
     */
    public function setInterval(intervalMs:int, handler:Function, params:Object = null, maxExecutionTimes:int = 0, listener:Object = null):BasicTimerObject {
        check(intervalMs, handler);
        const bto:BasicTimerObject = new BasicTimerObject(intervalMs, handler, params, maxExecutionTimes, BasicTimerObject.STATE_ACTIVE, listener);
        bto.nextExecutionTime = getTightTime() + intervalMs;
        basicTimerObjectsVector.push(bto);
        return bto;
    }

    /**
     * Removes related with object timers
     *
     * @param value - Object
     */
    public function removeAllTimersByObject(value:Object):void {
        for each (var bto:BasicTimerObject in basicTimerObjectsVector) {
            if (bto.linkedObject == value) bto.remove();
        }
    }

    public function removeAllTimers():void {
        for each (var bto:BasicTimerObject in basicTimerObjectsVector) {
            bto.remove();
        }
    }

    public function pauseAllTimers():void {
        timer.stop();
    }

    public function resumeAllTimers():void {
        timer.start();
    }

    public function set delay(value:int):void {
        timer.delay = value;
    }

    public static function get instance():BasicTimer {
        return __instance ? __instance : __instance = new BasicTimer();
    }
}
}
