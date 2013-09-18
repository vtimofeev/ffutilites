/**
 * @author: vtimofeev
 * @date: 01.03.13
 */
package com.timoff.services.log {
public class LocalLog {
    private var _caller:String;
    private var _log:Log;

    public function LocalLog(log:Log, caller:String) {
        _log = log;
        _caller = caller;
    }

    public function info(message:String):void {
        _log.info(message, _caller);
    }

    public function error(message:String):void {
        _log.error(message, _caller);
    }

    public function fatal(message:String):void {
        _log.fatal(message, _caller);
    }

    public function debug(message:String):void {
        _log.debug(message, _caller);
    }
}
}
