package com.framework.movieclipbitmap.core
{
import com.framework.movieclipbitmap.display.MovieClipSub;
import com.framework.movieclipbitmap.texture.Texture;
import com.framework.movieclipbitmap.utils.DisplayObjectParser;

import flash.display.FrameLabel;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

[Event(name="complete", type="flash.events.Event")]
[Event(name="rollOut", type="flash.events.MouseEvent")]
[Event(name="rollOver", type="flash.events.MouseEvent")]
/**
 *
 * @author Rakuten
 *
 */
public class Animatable extends MovieClip implements IAnimatable
{
    static public const VER:String = "1.1";
    /**
     * 分帧绘制bmd的间隔(单位:ms)
     */
    static public var PARSING_GAP:uint = 50;
    
    static protected var objParser:DisplayObjectParser = new DisplayObjectParser();
    /**
     * 保持一个point对象用于hitTestPoint，避免重复创建
     */
    static private var pot:Point = new Point();
    
    /**
     * 保存全局bmd素材的库
     */
    static public var globalMcLib:Object = {};
    
    static private const dic_mouseEvent:Array = [MouseEvent.CLICK,
                                                MouseEvent.DOUBLE_CLICK,
                                                MouseEvent.MOUSE_DOWN,
                                                MouseEvent.MOUSE_MOVE,
                                                MouseEvent.MOUSE_UP];
    
    /**
     *
     * @param sourceMc
     * @param autoDraw 是否自动生成Bitmap，如果为false则将在设置scale参数后再生成
     * @param fps 未开放功能，可以无视
     *
     */
    public function Animatable(sourceMc:MovieClip, autoDraw:Boolean = true, fps : int = 30)
    {
        this.mouseChildren = false;
        this.name = sourceMc.name;
        this.resourceName = sourceMc.name;
        this.sourceMc = sourceMc;
        this._fps = fps;
        this.sourceWidth = sourceMc.width;
        this.sourceHeight = sourceMc.height;
        if (autoDraw)
        {
            scale = sourceMc.scaleX;
        }
        for each (var i:FrameLabel in sourceMc.currentLabels)
        {
            this._currentLabels[i.name] = i.frame;
        }
    }
    
    protected var needAutoPlay:Boolean;
    
    /**
     * 供位图未生成前调用
     */
    protected var sourceWidth:Number = 1;
    /**
     * 供位图未生成前调用
     */
    protected var sourceHeight:Number = 1;
    
    /**
     * 因为引用的关系，有可能程序中所有的原图都为同一个，但也有可能不同
     * 一切需要看外部传进来的时候是什么
     */
    protected var sourceMc:MovieClip;
    protected var _currentMc:MovieClipSub;
    private var _timer:Timer;
    protected var _frameLimit:Number;
    protected var parserIndex:uint = 0;
    
    protected var _currentLabel:String;
    
    override public function get currentLabel():String
    {
        return _currentLabel;
    }
    
    
    /**
     * 帧标签容器
     */
    protected var _currentLabels:Object = {};
    
    
    private var resourceName:String;
    
    protected var _parsingComplete:Boolean;
    /**
     * mc是否已转换为序列帧动画 
     * @return 
     * 
     */
    public function get isParsingComplete():Boolean
    {
        return _parsingComplete;
    }
    
    /**
     * private
     * 资源回收使用
     */
    internal function get recycleToken():String
    {
        return resourceName+"-"+_scale;
    }
    
    private var _enableTransparentEvent:Boolean = true;
    public function get enableTransparentEvent():Boolean
    {
        return _enableTransparentEvent;
    }
    /**
     * 是否允许图片透明区域也可触发鼠标事件,默认为true
     * 如果设置为false将会降低性能
     * @param value
     *
     */
    public function set enableTransparentEvent(value:Boolean):void
    {
        _enableTransparentEvent = value;
        var key:String;
        if (!_enableTransparentEvent)
        {
            for (key in dic_mouseEvent)
            {
                addEventListener(key, testMouseEvent);
            }
            
            addEventListener(MouseEvent.ROLL_OVER, checkMouseInOut);
            addEventListener(MouseEvent.ROLL_OUT, checkMouseInOut);
        }
        else
        {
            for (key in dic_mouseEvent)
            {
                removeEventListener(key, testMouseEvent);
            }
            
            removeEventListener(MouseEvent.ROLL_OVER, checkMouseInOut);
            removeEventListener(MouseEvent.ROLL_OUT, checkMouseInOut);
        }
    }
    
    /**
     * 最小alpha通道值,点击、碰撞测试将其视为不透明的
     */
    private var _alphaThreshold:Number = 0.01;
    
    /**
     * 获取或设置最小alpha通道值,点击、碰撞测试将其视为不透明的
     */
    public function get alphaThreshold():Number
    {
        return _alphaThreshold / 255;
    }
    
    public function set alphaThreshold(value:Number):void
    {
        _alphaThreshold = value * 255;
    }
    
    override public function get width():Number
    {
        if (!_parsingComplete)
        {
            return sourceWidth*_scale;
        }
        return _currentMc.width*_scale;
    }
    
    override public function get height():Number
    {
        if (!_parsingComplete)
        {
            return sourceHeight*_scale;
        }
        return _currentMc.height*_scale;
    }
    
//		override public function set filters(value:Array):void
//		{
//
//		}
    
    protected var _scale:Number = 1;
    public function set scale(value:Number):void
    {
        _scale = value;
        if (sourceMc)
        {
            sourceMc.scaleX = value;
            sourceMc.scaleY = value;
            parser();
        }
    }
    
    public function get scale():Number
    {
        return _scale;
    }
    
    protected var _totalFrames:int;
    override public function get totalFrames():int
    {
        return _totalFrames;
    }
    
    protected var _currentFrame:int = 0;
    override public function get currentFrame():int
    {
        return _currentFrame;
    }
    
    protected var _fps:int = 30;
    public function get fps() : int
    {
        return _fps;
    }
    
    public function set fps(value : int) : void
    {
        _fps = value;
        if (_currentMc)
            _currentMc.fps = value;
    }
    
    public function get loop() : Boolean
    {
        return _currentMc.loop;
    }
    
    protected var needLoop:Boolean;
    public function set loop(value : Boolean) : void
    {
        if (_currentMc != null)
        {
            _currentMc.loop = value;
        }
        needLoop = value;
    }
    
    protected function getCurrentMcName(mcIndex:int):String
    {
        return resourceName+"-"+_scale+"-"+mcIndex;
    }
    
    override public function play() : void
    {
        if (_parsingComplete)
        {
            _currentMc.play();
        }
        else
        {
            this.needAutoPlay = true;
        }
    }
    
    override public function stop() : void
    {
        if (_currentMc)
            _currentMc.stop();
    }
    
    override public function nextFrame():void
    {
        var value:uint = _currentFrame;
        if (_currentFrame < _totalFrames)
        {
            value = _currentFrame + 1;
            gotoAndStop(value);
        }
    }
    
    override public function prevFrame():void
    {
        var value:uint = _currentFrame;
        if (_currentFrame != 1 && _currentFrame < _totalFrames)
        {
            value = _currentFrame - 1;
            gotoAndStop(value);
        }
    }
    
    override public function hitTestPoint(x:Number, y:Number, shapeFlag:Boolean = false):Boolean
    {
        if (shapeFlag)
        {
            pot.x = x;
            pot.y = y;
            pot = _currentMc.globalToLocal(pot);
            return !isPointTransparent(pot.x, pot.y);
        }
        else
        {
            return super.hitTestPoint(x, y, shapeFlag);
        }
    }
    
    override public function gotoAndStop(frame : Object, scene:String=null) : void
    {
        gotoFrame(frame)
    }
    
    override public function gotoAndPlay(frame : Object, scene:String=null) : void
    {
        gotoFrame(frame)
    }
    
    public function dispose():void
    {
        RecycleManager.remove(this);
    }
    
    /**
     * private
     * 由资源回收器调用，请不要手工调用
     */
    internal function recycle():void
    {
//			if (_currentMc)
//			{
        Juggler.getInstance().remove(this);
//			}
        
        var subMcTarget:MovieClipSub;
        for (var i:uint = 1; i<=this._totalFrames; i++)
        {
            var subName:String = getCurrentMcName(i);
            subMcTarget = globalMcLib[subName];
            subMcTarget.dispose();
            delete globalMcLib[subName];
        }
    }
    
    public function getFrameTexture(frame : int) : Texture
    {
        return _currentMc.getFrameTexture(frame);
    }
    
    /**
     * 重设某一帧的texture
     * @param frame			帧位置
     * @param texture		texture
     */
    public function setFrameTexture(frame : int, texture : Texture) : void
    {
        _currentMc.setFrameTexture(frame, texture);
    }
    
    private function isPointTransparent(x:int, y:int):Boolean
    {
        return (_currentMc.bitmapData.getPixel32(x, y) >> 24 & 0xff) < _alphaThreshold;
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
            Juggler.getInstance().remove(_currentMc);
//				_currentMc.stop();
            removeChild(_currentMc);
            _currentMc.clear();
            _currentMc = null;
        }
        _currentFrame = int(frame);
        var tmpMc:MovieClipSub = globalMcLib[getCurrentMcName(_currentFrame)];
        if (tmpMc)
        {
            _currentMc = tmpMc.clone();
            _currentMc.play();
            addChild(_currentMc);
            if (_currentMc.numChildren > 0)
            {
                Juggler.getInstance().add(_currentMc);
            }
        }
    }
    
    public function parser():void
    {
        parserIndex = 0;
        _totalFrames = sourceMc.totalFrames;
        startParsing(PARSING_GAP)
//			gotoAndPlay(1);
    }
    
    
//		private var parseTime:Number;
//		private var _lastFrameTime:Number;
    protected function startParsing(frameLimit:Number):void
    {
//			parseTime = getTimer();
        _frameLimit = frameLimit;
        if (!_timer || !_timer.running)
        {
            _timer = new Timer(_frameLimit, 0);
            _timer.addEventListener(TimerEvent.TIMER, onInterval);
            _timer.start();
        }
    }
    
    /**
     * Called when the parsing pause interval has passed and parsing can proceed.
     */
    protected function onInterval(event:TimerEvent = null):void
    {
//			_lastFrameTime = getTimer();
        if (proceedParsing())
            finishParsing();
    }
    
    /**
     * Finish parsing the data.
     */
    protected function finishParsing():void
    {
//            trace("解析耗时:"+(getTimer()-parseTime))
        RecycleManager.add(this);
        if (!_currentMc)
        {
            gotoAndPlay(1);
        }
        if (_timer) {
            _timer.removeEventListener(TimerEvent.TIMER, onInterval);
            _timer.stop();
            _timer = null;
        }
        _parsingComplete = true;
        dispatchEvent(new Event(Event.COMPLETE));
        
        _currentMc.loop = needLoop;
    }
    
    protected function proceedParsing():Boolean
    {
        return false;
    }
    
    public function advanceTime(time:Number):void
    {
        if (_currentFrame >= 0)
            _currentMc.advanceTime(time);
    }
    
    private var _mouseIn:Boolean;
    
    public function setMouseIn(value:Boolean):void
    {
        
        if (value == _mouseIn) return;
        _mouseIn = value;
        
        if (_mouseIn)
        {
            this.removeEventListener(MouseEvent.MOUSE_MOVE, checkMouseInOut);
            if (null != stage)
                stage.addEventListener(MouseEvent.MOUSE_MOVE, checkMouseInOut);
            
            this.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
        }
        else
        {
            this.addEventListener(MouseEvent.MOUSE_MOVE, checkMouseInOut);
            if (null != stage)
                stage.removeEventListener(MouseEvent.MOUSE_MOVE, checkMouseInOut);
            
            this.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
        }
    }
    
    private function checkMouseInOut(event:MouseEvent):void
    {
        event.stopImmediatePropagation();
        setMouseIn(!isPointTransparent(_currentMc.mouseX, _currentMc.mouseY));
    }
    
    private function testMouseEvent(event:MouseEvent):void
    {
        
        if (isPointTransparent(_currentMc.mouseX, _currentMc.mouseY))
        {
            event.stopImmediatePropagation();
        }
    }
}
}