/**
 * Created by IntelliJ IDEA.
 * User: Vasily
 * Date: 30.12.11
 * Time: 17:52
 * To change this template use File | Settings | File Templates.
 */
package com.timoff.services.loader.managers
{
public class LoadSettings
{

    // CACHE CONTEXT
    public var saveToCache:Boolean = true;
    public var loadFromCache:Boolean = true;

    // COMMON CONTEXT
    public var attempts:uint = 3;

    public var loadMode:uint = 0;

    // SWF CONTEXT
    public var useContext:Boolean = true;
    public var swfBinaryUnzippedStore:Boolean = false;

    public function LoadSettings(value:Object)
    {
    }


}
}
