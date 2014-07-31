package com.framework.movieclipbitmap.core
{
	/**
	 * 资源回收器
	 * 用于回收BitmapData，当引用计数为0时，消毁BitmapData 
	 * @author Rakuten
	 * 
	 */
	public class RecycleManager
	{
		public function RecycleManager()
		{
		}
		
		static private var lib:* = {};
		static public function add(obj:Animatable):void
		{
			var token:String = obj.recycleToken;
			if (!lib[token])
			{
				lib[token] = [];
			}
			lib[token].push(obj);
		}
		
		static public function remove(obj:Animatable):void
		{
			var token:String = obj.recycleToken;
			var arr:Array = lib[token];
			if (arr)
			{
				var index:int = arr.indexOf(obj);
				arr.splice(index,1);
//				trace("RecycleManager:"+arr.length)
				if (arr.length == 0)
				{
					obj.recycle();
					delete lib[token];
				}
//				trace("RecycleManager Memory:"+(System.totalMemory * 0.000000954).toFixed(3))
			}
		}
	}
}