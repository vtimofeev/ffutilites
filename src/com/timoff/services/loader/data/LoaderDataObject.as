package com.timoff.services.loader.data {
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

public class LoaderDataObject {
    public var url:String;
    public var content:Object;
    public var binary:ByteArray;

    public var bytes:Number = 0;
    public var requestCount:int = 0;
    public var applicationDomain:ApplicationDomain;
    public var time:Number = 0;

    public function LoaderDataObject(url:String, content:Object, binary:ByteArray = null) {
        if (!url)
            return;

        this.url = url;
        this.content = content;
        this.binary = binary;
    }
}
}