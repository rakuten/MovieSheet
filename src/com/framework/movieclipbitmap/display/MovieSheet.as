package com.framework.movieclipbitmap.display
{
import com.framework.movieclipbitmap.core.Animatable;
import com.framework.movieclipbitmap.core.Juggler;

import flash.display.DisplayObject;
import flash.display.MovieClip;

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

    override public function gotoAndStop(frame : Object, scene:String=null) : void
    {
        gotoFrame(frame)
    }
    
    override public function gotoAndPlay(frame : Object, scene:String=null) : void
    {
        gotoFrame(frame)
    }
    
    protected var _currentFrame:int = 0;
    override public function get currentFrame():int
    {
        return _currentFrame;
    }
    
    protected function gotoFrame(frame : Object):void
    {
        if (frame is String)
        {
            _currentLabel = String(frame);
            frame = _currentLabels[frame];
        }
        if (_currentMc)
        {
            Juggler.getInstance().remove(this);
            //				_currentMc.stop();
            removeChild(_currentMc);
            _currentMc.clear();
            _currentMc = null;
        }
        
        _currentFrame = int(frame);
        var tmpMc:MovieClipSub = globalMcLib[getCurrentMcName(int(frame))];
        if (tmpMc)
        {
            _currentMc = tmpMc.clone();
            _currentMc.play();
            addChild(_currentMc);
            if (_currentMc.numChildren > 0)
            {
                Juggler.getInstance().add(this);
            }
        }
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