package com.framework.movieclipbitmap.display
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import com.framework.movieclipbitmap.core.Animatable;

	/**
	 * MC序列动画，支持多帧多层子MovieClip对象，
     * 如需使用纯补间动画的mc，请使用MovieTween类
	 * @author Rakutens
	 */
	public dynamic class MovieSheet extends Animatable
	{
        /**
         *
         * @param sourceMc
         * @param autoDraw 是否自动生成Bitmap，如果为false则将在设置scale参数后再生成
         * @param fps 未开放功能，可以无视
         *
         */
		public function MovieSheet(sourceMc:MovieClip, autoDraw:Boolean = true, fps : int = 30)
		{
			super(sourceMc, autoDraw, fps);
		}

		override protected function proceedParsing():Boolean
		{
			parserIndex++;
			sourceMc.gotoAndStop(parserIndex);
			if (!globalMcLib[getCurrentMcName(parserIndex)])
			{
				var mc:DisplayObject;

				if (sourceMc.numChildren <= 0)
				{
					//帧内无对象
					mc = new MovieClip();
				}
				else if (sourceMc.numChildren > 1)
				{
					//有多层，帧内不止一个可视对象
					mc = sourceMc;
				}
				else
				{
					//帧内只有一个可视对象
					mc = sourceMc.getChildAt(0) as MovieClip
				}

				var subMcTarget:MovieClipSub;
				if (mc)
				{
					if (sourceMc.currentFrameLabel)
					{
						currentLabels[sourceMc.currentFrameLabel] = parserIndex;
					}
					subMcTarget = new MovieClipSub(objParser.renderToTextures(mc as MovieClip), _fps);
					subMcTarget.name = mc.name+"|"+parserIndex;
					subMcTarget.isSwfMC = true;
					globalMcLib[getCurrentMcName(parserIndex)] = subMcTarget;
				}
			}
			return parserIndex == _totalFrames;
		}
	}
}