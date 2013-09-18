package com.timoff.services.log {

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.utils.Dictionary;

public class Log {
    internal static const DEBUG:int = 0x07;
    internal static const INFO:int = 0x05;
    internal static const ERROR:int = 0x02;
    internal static const FATAL:int = 0x01;

    internal static const INFO_COLOR:String =  '#000000';
    internal static const ERROR_COLOR:String = '#FF0000';
    internal static const DEBUG_COLOR:String = '#CC44CA';
    internal static const FATAL_COLOR:String = "#990000";

    private var log:Vector.<LogDataObject> = new Vector.<LogDataObject>;
    private var logLength:int = 32000;
    private var _facadeName:String = 'default';
    private var _shortFacadeName:String = 'default';
    private var outTargets:Dictionary;
    private var inTargets:Array = [];

    private var _stage:Stage = null;
    private var viewInstance:Sprite = null;
    private var tf:TextField = null;

    private var codesSequence:String = '19282';
    private var currentSequence:String = '';

    private static var _instances:Object = {};

    public static var logLevel:int = 0x07;
    public static var enableTrace:Boolean = true;
    public static var enableKeyboardListeners:Boolean = true;

    public function Log(facadeName:String, shortFacadeName:String = null, level:int = INFO, length:int = 10000) {
        _facadeName = facadeName;
        _shortFacadeName = shortFacadeName ? shortFacadeName : facadeName.substr(0, 2).toUpperCase();
        logLength = length;
    }

    //----------------------------------------------------------------------------
    //
    //----------------------------------------------------------------------------


    public function info(message:String, caller:* = null):void {
        if (logLevel < INFO) return;

        var lo:LogDataObject = new LogDataObject(message, INFO, caller);
        log.push(lo);
        out(lo);
    }

    public function error(message:String, caller:* = null):void {
        if (logLevel < ERROR) return;

        var lo:LogDataObject = new LogDataObject(message, ERROR, caller);
        log.push(lo);
        out(lo);
    }

    public function fatal(message:String, caller:* = null):void {
        if (logLevel < ERROR) return;

        var lo:LogDataObject = new LogDataObject(message, FATAL, caller);
        log.push(lo);
        out(lo);
    }

    public function debug(message:String, caller:* = null):void {
        if (logLevel < DEBUG) return;

        var lo:LogDataObject = new LogDataObject(message, DEBUG, caller);
        log.push(lo);
        out(lo);
        return;
    }

    public function getLocalLog(caller:String):LocalLog
    {
        return new LocalLog(this, caller);
    }

    //----------------------------------------------------------------------------
    // out targets
    //----------------------------------------------------------------------------

    public function registerOutTarget(value:Object):void
    {
        outTargets[value] = value;
    }

    public function removeOutTarget(value:Object):void
    {
        outTargets[value] = value;
    }

    //------------------------------------------------------------------------------
    // register in targets
    //------------------------------------------------------------------------------

    public function set targetInterests(value:Array):void
    {
        if(!inTargets) inTargets = [];
        inTargets = value;
    }

    public function get targetInterests():Array
    {
        return inTargets;
    }

    public function hasInTargetInterest(value:String):Boolean
    {
        return inTargets.length?inTargets.indexOf(value)>=0:true;
    }

    //------------------------------------------------------------------------------
    // actions
    //------------------------------------------------------------------------------

    private function out(lo:LogDataObject):void {

        if (enableTrace && lo) trace(lo.toString());

        for each(var outTarget:* in outTargets)
        {
            if(outTarget is TextField) outTarget.htmlText = lo.toHtmlString() + outTarget.htmlText;
        }
        return;
    }

    //-------------------------------------------------------------------------
    // Todo: extract view instance
    //-------------------------------------------------------------------------

    public function registerStage(stage:Stage):void {
        _stage = stage;
        _stage.addEventListener(KeyboardEvent.KEY_UP, keyboardHandler, false, 0, true)
    }

    private function keyboardHandler(event:KeyboardEvent):void {
        if (!enableKeyboardListeners) return;

        currentSequence += event.keyCode.toString();

        if (event.keyCode == 192)
        {
            if (viewInstance != null)
                hideView();
        }
        else
        if (currentSequence.indexOf(codesSequence, 0) >= 0) {
            showView();
            currentSequence = '';
        }
        return;
    }

    private function hideView():void {
        _stage.removeChild(viewInstance);
        tf = null;
        viewInstance = null;
        return;
    }

    private function showView():void {
        viewInstance = new Sprite();
        _stage.addChild(viewInstance);
        {
            var bg:Sprite = new Sprite();
            bg.graphics.lineStyle(2, 0xFF0000, 1);
            bg.graphics.beginFill(0xFFFFFF, 0.7);
            bg.graphics.drawRect(10, 40, _stage.stageWidth - 20, _stage.stageHeight - 50);
            bg.graphics.endFill();

            viewInstance.addChild(bg);

            tf = new TextField();
            tf.width = _stage.stageWidth - 20;
            tf.height = _stage.stageHeight - 50;
            tf.x = 10;
            tf.y = 40;
            tf.background = false;
            tf.border = false;
            tf.multiline = true;

            tf.htmlText += "...";
            tf.textColor = 0x000000;
            tf.borderColor = 0x000000;

            viewInstance.addChild(tf);
            registerOutTarget(tf);
        }
        updateOut();
        return;
    }

    private function updateOut():void {
        if (!tf) return;

        var length:int = log.length;
        var result:String = tf.text;

        for (var i:int = 0; i < length; i++)
            result = log[i].toHtmlString() + result;

        tf.htmlText = result;
        return;
    }


    /* Depricated */
    public static function getInstance(facadeName:String):Log {
        if (!_instances[facadeName]) {
            _instances[facadeName] = new Log(facadeName, facadeName.toUpperCase().substr(0,2));
        }
        return _instances[facadeName];
    }



    public static function getInstanceByFacade(facadeName:String):Log {
        if (!_instances[facadeName]) {
            _instances[facadeName] = new Log(facadeName, facadeName.toUpperCase().substr(0,2));
        }
        return _instances[facadeName];
    }

}
}