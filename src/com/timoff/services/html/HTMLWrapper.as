package com.timoff.services.html
{
	public class HTMLWrapper
	{
		public static function font ( text:String , color:String ):String
		{
			return '<font color="' + color + '">' + text + '</font>';
		}
	}
}