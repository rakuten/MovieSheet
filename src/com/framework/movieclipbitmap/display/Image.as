package com.framework.movieclipbitmap.display
{
import com.framework.movieclipbitmap.texture.Texture;

import flash.display.Bitmap;

/**
 * 简单的显示图片,没有任何监听事件 
 * @author Neil
 */	
public class Image extends Bitmap
{
	
	protected var texture : Texture;
			
	public function Image(texture : Texture)
	{
		this.texture = texture;
		this.bitmapData = texture.bitmapData;
		this.smoothing = true;
//		this.x = texture.x;
//		this.y = texture.y;
//		this.width = texture.width;
//		this.height = texture.height;
	}
}
}