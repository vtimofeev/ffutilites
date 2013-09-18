/**
 * Author: Vasily Timofeev
 * Web: http://timoff.com
 */
package com.timoff.utilites {
import flash.system.Capabilities;
import flash.system.System;

public class FlashPlayerInfo {

    public static const OS_UNKNOWN_ID:int = -1;
    public static const OS_WIN_ID:int = 0;
    public static const OS_MAC_ID:int = 1;
    public static const OS_LINUX_ID:int = 2;
    public static const OS_IPHONE_ID:int = 3;

    public static const RUNTIME_UNKNOW_ID:int = -1;
    public static const RUNTIME_BROWSER_ID:int = 0;
    public static const RUNTIME_AIR_DESKTOP_ID:int = 1;
    public static const RUNTIME_EXTERNAL_ID:int = 2;
    public static const RUNTIME_STAND_ALONE_ID:int = 3;

    private static var __instance:FlashPlayerInfo;
    private var _majorVersion:int = 0;
    private var _minorVersion:int = 0;
    private var _version:Number = 0;
    private var _os:String = '';
    private var _language:String = 'en';
    private var _runtimeType:int = 0;


    public function FlashPlayerInfo() {
        const flashPlayerVersion:String = Capabilities.version;
        const osArray:Array = flashPlayerVersion.split(' ');
        const versionArray:Array = osArray[1].split(',');

        _majorVersion = parseInt(versionArray[0]);
        _minorVersion = parseInt(versionArray[1]);
        _version = parseFloat(_majorVersion.toString() + "." + _minorVersion.toString())
        _os = Capabilities.os;
        _language = Capabilities.language;
        _runtimeType = getRuntimeType(Capabilities.playerType);

    }

    private function getRuntimeType(playerType:String):int {
        var result:int = RUNTIME_UNKNOW_ID;
        result = playerType == 'ActiveX'?RUNTIME_BROWSER_ID:playerType == 'PlugIn'?RUNTIME_BROWSER_ID:result;
        result = playerType == 'External'?RUNTIME_EXTERNAL_ID:result;
        result = playerType == 'Desktop'?RUNTIME_AIR_DESKTOP_ID:result;
        result = playerType == 'StandAlone'?RUNTIME_STAND_ALONE_ID:result;
        return result;
    }

    /*
      Get major fp version
     */
    public function get majorVersion():int {
        return _majorVersion;
    }

    /*
        Get minor fp version
     */
    public function get minorVersion():int {
        return _minorVersion;
    }

    /*
        Get version ( major point minor as number )
     */
    public function get version():Number {
        return _version;
    }

    /*
        Get os ( string like Windows 7 or MAC OS X.Y.Z )
     */
    public function get os():String {
        return _os;
    }

    /*
        Get os id by const.
     */
    public function get osId():int {
        var result:int = OS_UNKNOWN_ID;
        var oslc:String = os.toLowerCase();

        result = oslc.indexOf("windows") == 0?OS_WIN_ID:result;
        result = oslc.indexOf("mac") == 0?OS_MAC_ID:result;
        result = oslc.indexOf("linux") == 0?OS_LINUX_ID:result;
        result = oslc.indexOf("iphone") == 0?OS_IPHONE_ID:result;

        return result;
    }

    /*
        Get language code of system like 'en' or 'ru' string.
     */
    public function get language():String {
        return _language;
    }

    /*
        Get player type ( browser, air ... )
     */
    public function get runtimeType():int {
        return _runtimeType;
    }

    // -----------------------------------------------------------------
    // Static methods
    // -----------------------------------------------------------------

    public static function get instance():FlashPlayerInfo {
        return __instance ? __instance : __instance = new FlashPlayerInfo();
    }



}
}
