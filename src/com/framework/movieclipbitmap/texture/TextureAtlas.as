package com.framework.movieclipbitmap.texture
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
    
    public class TextureAtlas
    {
		private var destPoint : Point = new Point(0, 0);
		/** 序列图数据 */
		private var datas:BitmapData;
		/** 缓存所有texture名称 */
		private var names : Vector.<String>;
		/** 缓存所有texture对象 */
		private var textures : Vector.<Texture>;
					
		/**
		 * 根据texture以及xml配置获取texture 
		 * @param bitmapData	序列图
		 * @param atlasXml		配置文件
		 */		
        public function TextureAtlas(data:BitmapData, atlasXml:XML=null)
        {
			
			if(data == null)
				throw new Error('data is null' );
			if(atlasXml == null)
				throw new Error('xml is null');
			
			names = new Vector.<String>();
			textures = new Vector.<Texture>();
			
            datas = data;
			
            if (atlasXml)
                parseAtlasXml(atlasXml);
			
        }
        
        public function dispose():void
        {
            datas.dispose();
        }
        
		/**
		 * 解析xml 
		 * @param atlasXml
		 */		
        protected function parseAtlasXml(atlasXml:XML):void
        {
            for each (var subTexture:XML in atlasXml.SubTexture)
            {
                var name:String        = subTexture.attribute("name");
                
				var x:Number           = parseFloat(subTexture.attribute("x"));
                var y:Number           = parseFloat(subTexture.attribute("y")) ;
                var width:Number       = parseFloat(subTexture.attribute("width"));
                var height:Number      = parseFloat(subTexture.attribute("height"));
				
				var sourceRect : Rectangle = new Rectangle(x, y, width, height);
								
				var data : BitmapData = new BitmapData(width, height, true, 0);
				data.copyPixels(datas, sourceRect, destPoint);
				
				var frameRect : Rectangle = new Rectangle(0, 0, width, height);
				
				var texture : Texture = new Texture(data, frameRect);
				
				names.push(name);
				textures.push(texture);
            }
        }
        
		/**
		 * 根据名称获取texture 
		 * @param name			texture名称
		 * @return 				texture
		 */		
        public function getTexture(name:String):Texture
        {
			var index : int = names.indexOf(name);
			if(index == -1)
				return null;
			else
				return textures[index];
        }
        
		/**
		 * Returns all texture names that start with a certain string
		 * @param prefix	名称以prefix开头的所有texture均会被取出
		 * @return 			Vector.<Texture>
		 */		
        public function getTextures(prefix:String):Vector.<Texture>
        {
			var result : Vector.<Texture> = new Vector.<Texture>();
			var len : int = names.length;
			for (var i : int = 0; i < len; i++)
			{
				var name : String = names[i];
				// 只要以prefix开头的texture都会被添加进来
				if(name.indexOf(prefix) == 0)
					result.push(textures[i]);
			}
			return result;
        }
		
    }
}