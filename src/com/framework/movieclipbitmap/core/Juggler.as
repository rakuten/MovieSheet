package com.framework.movieclipbitmap.core
{

import flash.display.MovieClip;
import flash.display.Stage;
import flash.events.Event;
import flash.utils.getTimer;

/**
 * 动画引擎
 * @author Neil
 */
public class Juggler
{
    static private var instance:Juggler;
    public static function getInstance() : Juggler {
        return instance ||= new Juggler();
    }
    
    /** 舞台 */
    private var stage : Stage;
    /** 最后时间 */
    private var lastFrameTimeStamp : Number = 0;
    /** 一秒 */
    private var second : Number = 1000.0;
    /** 所有ianimatable对象 */
    private var iAnimatableObjects : Vector.<IAnimatable>;
    /** 过去的时间 */
    private var elapsedTime : Number = 0;
    
    static private var mc:MovieClip = new MovieClip();
    /**
     * @param single
     */
    public function Juggler()
    {
        this.iAnimatableObjects = new Vector.<IAnimatable>();
        this.elapsedTime = 0;
        start();
    }
    
    /**
     * 增加动画 
     * @param animator	动画
     */		
    public function add(animator : IAnimatable) : void
    {
        if (animator != null && iAnimatableObjects.indexOf(animator) == -1)
        {
            iAnimatableObjects.push(animator);
        }
    }
    
    /**
     * 移除动画 
     * @param animator	动画
     */		
    public function remove(animator : IAnimatable) : void
    {
        if (animator == null)
            return;
        var index : int = iAnimatableObjects.indexOf(animator);
        if (index != -1)
            iAnimatableObjects[index] = null;
    }
    
    public function start() : void
    {
        this.lastFrameTimeStamp = getTimer() / second;
        mc.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    
    public function stop() : void
    {
        mc.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    
    /**
     * 帧循环
     * ------------------------------------------------
     * 调用所有实现IAnimatable接口的对象的advanceTime方法
     * ------------------------------------------------
     * 有很大的几率会出现在播放动画的时候，IAnimatable被移除
     *
     * @param event
     */
    protected function onEnterFrame(event : Event) : void
    {
        // 当前时间 
        var now : Number = getTimer() / second;
        // 过去的时间
        var passedTime : Number = now - lastFrameTimeStamp;
        var numObjects : int = iAnimatableObjects.length;
        var currentIndex : int = 0;
        var i : int = 0;
        elapsedTime += passedTime;
        
        if (numObjects == 0)
            return;
        
        // 假设第二个突然为null
        for (i = 0; i < numObjects; i++)
        {
            var animator : IAnimatable = iAnimatableObjects[i];
            if (animator != null)
            {
                if (currentIndex != i)
                {
                    iAnimatableObjects[currentIndex] = animator;
                    iAnimatableObjects[i] = null;
                }
                animator.advanceTime(passedTime);
                currentIndex++;
            }
        }
        if (currentIndex != i)
        {
            // 长度有可能变化
            numObjects = iAnimatableObjects.length;
            while (i < numObjects)
                iAnimatableObjects[currentIndex++] = iAnimatableObjects[i++];
            iAnimatableObjects.length = currentIndex;
        }
        
    }
}
}
