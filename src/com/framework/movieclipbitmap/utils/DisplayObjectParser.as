package com.framework.movieclipbitmap.utils
{
	import com.framework.movieclipbitmap.texture.Texture;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	
	/**
	 * 将DisplayObject转化为texture数组
	 * @author Neil
	 */	
	public class DisplayObjectParser
	{
		static private var mat:Matrix = new Matrix();
		
		public function DisplayObjectParser()
		{
		}
		
		/**
		 * 
		 * @param mc
		 * @param isTween 是否为补间动画类型(由MovieTween调用)
		 * @return 
		 * 
		 */		
		public function renderToTextures(mc:MovieClip, isTween:Boolean = false) : Vector.<Texture>
		{
			
			if(mc == null)
				throw new Error('MovieClip is null');
			
			var total:int
			if (mc.parent || isTween)
			{
				total = mc.totalFrames;
				mc.gotoAndStop(1);
			}
			else
			{
				total = 1;
			}
			var textures : Vector.<Texture> = new Vector.<Texture>(total, true);
			var i : int = 0;
			while(i < total)
			{
				textures[i] = renderToTexture(mc, true, 0x000000);
				if (total > 1)
				{
					mc.nextFrame();
				}
				i++;
			}
			return textures;
		}
		
		public function renderToTexture(source:DisplayObject, transparent:Boolean = true, fillColor:uint = 0x00000000) : Texture
		{
			if(source == null)
				throw new Error('DisplayObject is null');
			
			var drawSource:DisplayObject;
			var needUnPack:Boolean;
			if (source.parent)
			{
				drawSource = source.parent;
			}
			else
			{
				needUnPack = true;
				var target:Sprite = new Sprite();
				target.addChild(source);
				drawSource = target;
			}
			var rect:Rectangle = source.getBounds(drawSource);
			//防止 "无效的 BitmapData"异常
			if (rect.isEmpty())
			{
				rect.width = 1;
				rect.height = 1;
			}
			var bitmapData:BitmapData = copyDisplayAsBmd(drawSource, transparent);
			var texture : Texture = new Texture(bitmapData, rect, drawSource.scaleX);
			if (needUnPack)
			{
				DisplayObjectContainer(drawSource).removeChild(source);
			}
			return texture;
		}
		
		public static function copyDisplayAsBmd(obj:DisplayObject, transparent:Boolean = true) : BitmapData
		{
			var sourceScaleY:Number = obj.scaleY;
			var sourceScaleX:Number = obj.scaleX;
			var rect:Rectangle = obj.getBounds(obj);
			var bmd:BitmapData = new BitmapData(obj.width ? obj.width : 1, obj.height ? obj.height+1 : 1, transparent, 0);
			
			if (sourceScaleX < 0)
			{
				obj.scaleX = -obj.scaleX;
			}
			if (sourceScaleY < 0)
			{
				obj.scaleY = -obj.scaleY;
			}
			mat.createBox(obj.scaleX, obj.scaleY, 0, (-rect.x) * obj.scaleX, (-rect.y) * obj.scaleY);
			bmd.draw(obj, mat);
			obj.scaleX = sourceScaleX;
			obj.scaleY = sourceScaleY;
//			var bmp:Bitmap = new Bitmap(bmd, PixelSnapping.AUTO, param2);
//			if (sourceScaleY < 0)
//			{
//				bmp.scaleX = -1;
//			}
//			if (sourceScaleX < 0)
//			{
//				bmp.scaleY = -1;
//			}
//			bmp.x = obj.x * sourceScaleX;
//			bmp.y = obj.y * sourceScaleY;
//			return bmp;
			return bmd;
		}
	}
}