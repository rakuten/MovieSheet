package com.framework.movieclipbitmap.core
{
import flash.display.DisplayObjectContainer;

	/**
	 * 动画接口 
	 * @author Neil
	 */	
	public interface IAnimatable
	{
		/**
		 *  
		 * @param time
		 * 
		 */		
		function enterFrame(time:Number) : void;
        
        function get parent():DisplayObjectContainer
	}
}