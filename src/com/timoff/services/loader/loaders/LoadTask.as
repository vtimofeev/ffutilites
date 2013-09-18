package com.timoff.services.loader.loaders
{
import com.timoff.services.loader.managers.LoadSettings;

import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.getTimer;

    import com.timoff.services.cache.Cache;
	import com.timoff.services.loader.data.*;
	import com.timoff.services.loader.events.*;
	import com.timoff.services.loader.interfaces.*;
	
	public class LoadTask
	{
		public var target:ILoaderClient;
		public var urls:Object={};
		public var result:Array=[];
		public var isComplete:Boolean=false;

		public var loadFromCache:Boolean=true;
		public var saveToCache:Boolean=true;

		private var lastProgressEventTime:Number=0;
		private var progressEventMinInterval:int=100;
        public var loadSettings:LoadSettings;
		
		/**
		 * Constructor, checks urls in cache ( if option's enabled ), 
		 * creates load task url array. 
		 *  
		 * @param target
		 * @param urls
		 * @param useCache
		 * @param saveToCache
		 * @param useContext
		 * 
		 */
		public function LoadTask(target:ILoaderClient, urls:Array, loadSettings:LoadSettings)
		{
			var cache:LoaderDataObject;
			
			if (!target)
				throw new Error("Client of DataLoaderManager is NULL, please set all properties");
			
			
			this.target=target;
            this.loadSettings = loadSettings;
			this.loadFromCache=loadSettings.loadFromCache;
			this.saveToCache=loadSettings.saveToCache;


			for each (var url:String in urls)
			{
				if (!url)
				{
					continue;
				}
				cache=null;
				
				if (loadFromCache)
				{
					cache= Cache.instance.getData(url);
				}
				
				this.urls[url]=LoadState.WAITING;
			}
		}
		
		/**
		 * Add listeners to DataLoader which services this LoadTask.
		 * It's called by DataLoaderManager.
		 *  
		 * @param loader
		 * 
		 */
		public function addResultListener(loader:DataLoader):void
		{
			urls[loader.loadedUrl]=LoadState.LOADING;
			loader.addEventListener(LoaderEvent.EVENT_COMPLETE, resultHandler, false, 0, true);
			loader.addEventListener(LoaderEvent.EVENT_ERROR, resultHandler, false, 0, true);
			
			(target is IAdvLoaderClient) ? loader.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true) : null;
			
			
			return;
		}
		
		/**
		 * Returns unloaded urls are.
		 *  
		 * @return Boolean
		 * 
		 */
		public function get hasWaitingItems():Boolean
		{
			var result:int=0;
			for (var url:String in urls)
			{
				if (urls[url] == LoadState.WAITING)
				{
					result++;
				}
			}
			
			return result > 0;
		}
		
		/**
		 * Returns next unloaded url
		 *  
		 * @return 
		 * 
		 */
		public function get nextWaitingItem():String
		{
			var result:int=0;
			for (var url:String in urls)
			{
				if (urls[url] == LoadState.WAITING)
				{
					return url;
				}
			}
			
			return null;
		}
		
		/**
		 * It refreshes the urls, for example when one item of the url is loaded.   
		 * 
		 */
		public function refresh():void
		{
			var cache:LoaderDataObject;
			if (!loadFromCache)
				return;
			
			for (var url:String in urls)
			{
				if (urls[url] != LoadState.WAITING)
				{
					continue;
				}
				
				cache=Cache.instance.getData(url);

				if (cache && !cache.binary)
				{
					trace("LT::getFromCache " + url);
					var event:LoaderEvent=new LoaderEvent(LoaderEvent.EVENT_COMPLETE, cache)
					resultHandler(event);
				}
			}
			
			return;
		}
		
		private function get countLoadedItems():int
		{
			var result:int=0;
			for (var url:String in urls)
			{
				if (urls[url] >= LoadState.LOADED_WITH_ERRORS)
				{
					result++;
				}
			}
			
			return result;
		}
		
		protected function get countItems():int
		{
			var result:int=0;
			for (var url:String in urls)
			{
				result++;
			}
			
			return result;
		}
		
		protected function resultHandler(event:Event):void
		{
			var loader:DataLoader=event.target as DataLoader;
			var levent:LoaderEvent=event as LoaderEvent;
			var result:int= (event.type == LoaderEvent.EVENT_COMPLETE) ? LoadState.LOADED : LoadState.LOADED_WITH_ERRORS;
			
			this.result.push(event);
			
			if (levent)
			{
				urls[levent.data.url]=result;
				if (saveToCache)
				{
					Cache.instance.setData(levent.data);
				}
			}
			
			if (loader)
			{
				urls[loader.loadedUrl]=result;
				freeLoader(loader);
			}
			
			if (result == LoadState.LOADED_WITH_ERRORS)
				trace("loaded with errors: " + levent.data.url);
			
			refreshTask();
			return;
		}
		
		protected function progressHandler(event:ProgressEvent):void
		{
			if (lastProgressEventTime + progressEventMinInterval > getTimer())
				return;
			
			lastProgressEventTime=getTimer();


            var result:Number=((event.bytesLoaded / event.bytesTotal) + countLoadedItems) / countItems;
			(target as IAdvLoaderClient).progressHandler(new LoaderProgressEvent(result));

            if(target.stopped)
            {
                DataLoader(event.currentTarget).stop();
            }
        }
		
		protected function refreshTask():void
		{
			var complete:Boolean=true;
			var errors:Boolean=false;
			
			for (var url:String in urls)
			{
				if (urls[url] < LoadState.LOADED_WITH_ERRORS)
				{
					complete=false;
				}

				if (urls[url] == LoadState.LOADED_WITH_ERRORS)
				{
					errors=true;
				}
			}

            if(target.stopped)
            {
                for (var url:String in urls)
                {
                    if (urls[url] < LoadState.LOADED_WITH_ERRORS)
                    {
                        urls[url] = LoadState.LOADED_WITH_ERRORS
                    }
                }
                complete = true;
            }

			if (target is IAdvLoaderClient)
			{
				(target as IAdvLoaderClient).progressHandler(new LoaderProgressEvent(countLoadedItems / countItems));
			}
			
			if (!complete)
			{
				return;
			}

			var loaderEvent:LoaderEvent;
			isComplete=true;

			if (complete && !errors)
			{
				loaderEvent=new LoaderSuccessEvent(LoaderEvent.EVENT_COMPLETE);
				loaderEvent.result=this.result;
				target.successHandler(loaderEvent);
			}
			
			if (complete && errors)
			{
				loaderEvent=new LoaderErrorEvent(LoaderEvent.EVENT_ERROR);
				loaderEvent.result=this.result;
				(loaderEvent as LoaderErrorEvent).errors = this.result;
				target.errorHandler(loaderEvent);
			}

			return;
		}
		
		/**
		 * Removes listener from DataLoader which services url of LoadTask.		 
		 *  
		 * @param loader
		 * 
		 */
		protected function freeLoader(loader:DataLoader):void
		{
			loader.removeEventListener(LoaderEvent.EVENT_COMPLETE, resultHandler);
			loader.removeEventListener(LoaderEvent.EVENT_ERROR, resultHandler);
			
			(target is IAdvLoaderClient) ? loader.removeEventListener(ProgressEvent.PROGRESS, progressHandler) : null;
		}
		
		/**
		 * Frees refereces  
		 * 
		 */
		public function free():void
		{
			target = null;
			urls = null;
			result = null;
		}
	}
}