package com.timoff.services.so                                   
{
	import flash.net.SharedObject;

	public class SharedObjectManager
	{
		private static var _instance:SharedObjectManager;
		
		private var repository:SharedObject;
		

		public function SharedObjectManager(storage:String)
		{	
			if (!storage)
			{
				throw new Error ("SharedObjectManager:: Can't create storage without name");
			}
					
			repository = SharedObject.getLocal(storage);
		}
		
		public function getObject ( name:String ):Object
		{
			if( repository.data.hasOwnProperty(name) )				
				return repository.data[name];
			return null;
		}
		
		public function setObject ( name:String , value:Object , save:Boolean = false ):void
		{			
			repository.data[name] = value;
            if (save) flush();
		}
		
		protected function flush():void
		{
            try {
               repository.flush();
            }
            catch (e:Error)
            {
                trace("Flush.error :: " + e.message);
            }
		}

        public static function getInstance(storage:String):SharedObjectManager
        {
            return (!_instance)?_instance = new SharedObjectManager(storage):_instance;
        }

	}
}