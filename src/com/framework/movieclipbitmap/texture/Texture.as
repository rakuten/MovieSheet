package com.framework.movieclipbitmap.texture
{
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * texture(bitmapdata)
 * 宽度、高度、起始坐标 
 * @author Neil
 */    
public class Texture
{
    /** 数据 */
    private var _bitmapData : BitmapData;
    /** 帧x位置 */
    internal var frameX : Number = 0;
    /** 帧y位置 */
    internal var frameY : Number = 0;
    /** 宽度 */
    internal var frameWidth : Number = 0;
    /** 高度 */
    internal var frameHeight : Number = 0;
    
    internal var scale:Number = 1;
    
    /**
     * 创建texture 
     * @param data			bitmapdata数据
     * @param frameRect 	帧起点以及宽度数据
     */		
    public function Texture(data:BitmapData, frameRect:Rectangle=null, scale:Number = 1)
    {
        if (frameRect)
        {
            this.frameWidth = frameRect.width
            this.frameHeight = frameRect.height;
            this.frameX = frameRect.x * scale;
            this.frameY = frameRect.y * scale;
        }
        _bitmapData = data;
    }
    
    public function get x() : Number
    {
        return frameX;
    }
    
    public function set x(value : Number) : void
    {
        frameX = value;
    }
    
    public function set y(value : Number) : void
    {
        frameY = value;
    }
    
    public function get y() : Number
    {
        return frameY;
    }
    
    public function get height():Number
    {
        return this.frameHeight;
    }
    
    public function get width() : Number
    {
        return this.frameWidth;
    }
    
    public function get bitmapData():BitmapData
    {
        return _bitmapData;
    }
    
    public function dispose():void
    { 
        bitmapData.dispose();
    }
    
    public function clone():Texture
    {
        var cloneTexture:Texture = new Texture(_bitmapData, null);
        cloneTexture.frameHeight = this.frameHeight;
        cloneTexture.frameWidth = this.frameWidth;
        cloneTexture.frameX = this.frameX;
        cloneTexture.frameY = this.frameY;
        cloneTexture.scale = this.scale;
        return cloneTexture;
    }
    
}
}