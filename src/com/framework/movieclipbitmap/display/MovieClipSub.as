package com.framework.movieclipbitmap.display
{
	import com.framework.movieclipbitmap.texture.Texture;
	
	
	/**
	 * 位图动画引擎，需要被加入到juggler才可以被播放
	 * 之前考虑过直接使用bitmap来做，但是对于每一帧的
	 * 位置不好控制，只能通过移动bitmap的位置来实现，
	 * 因此bitmap位置发生改变，不是mc的实现方式
	 * ----------------------------------------
	 * 构造方法传入位图序列即可
	 * ----------------------------------------
	 * @author Neil
	 */
	public class MovieClipSub extends Image
	{
		/** 序列图 */
		private var _textures : Vector.<Texture>;
		/** 总帧数 */
		private var _totalFrame : int = 0;
		/** 当前帧 */
		private var _currentFrame : int = 0;
		/** 当前帧的时间(用于因为降频，做丢帧操作。指：本该显示，但是因为降频它不应该显示出来) */
		private var _currentTime : Number = 0;
		/** 存放每一帧的播放时间, 为以后插帧，插声音设计 */
		private var _durations : Vector.<Number>;
		/** 每一帧的开始时间 */
		private var _startTimes : Vector.<Number>;
		/** 默认的每一帧播放时间,根据帧频算出默认时间 */
		private var _defaultFrameDuration : Number;
		/** 播放这个动画一共需要的时间 */
		private var _totalTime : Number;
		/** 是否循环播放 */
		private var _loop : Boolean;
		/** 是否处于播放状态 */
		private var _playing : Boolean;
		/** fps */
		private var _fps : int = 0;
		
		/** 控制位置是否跟随texture变化 */
		private var _isSwfMC : Boolean = false;
		
		/**
		 * 构造一个movieclip
		 * @param textures	位图序列
		 * @param fps		帧频
		 */
		public function MovieClipSub(textures : Vector.<Texture> = null, fps : int = 30)
		{
			if (textures.length > 0)
			{
				super(textures[0]);
				this.x = textures[0].x;
				this.y = textures[0].y;
				init(textures, fps);
			}
			else
			{
				throw new Error("textures is empty");
			}
		}
		
		public function get numChildren():uint
		{
			return _textures.length;
		}
		
		public function set isSwfMC(value : Boolean) : void
		{
			_isSwfMC = value;
		}
		
		public function get totalFrames():int
		{
			return this._totalFrame;
		}
		
		public function get currentFrame():int
		{
			return this._currentFrame;
		}

		/**
		 * 初始化movieclip
		 * @param textures	位图序列
		 * @param fps		帧频
		 */
		private function init(textures : Vector.<Texture>, fps : int = 30) : void
		{
			if (fps <= 0)
				throw new ArgumentError("invalid fps: " + fps);
			var numFrames : int = textures.length;
			// 计算默认每一帧的时间
			_fps = fps;
			_defaultFrameDuration = 1.0 / fps;
			_totalFrame = numFrames;
			_loop = true;
			_playing = false;
			_currentTime = 0.0;
			_currentFrame = 0;
			_totalTime = _defaultFrameDuration * numFrames;
			_textures = textures.concat();
			// todo:以后会加入插帧即addFrameAt
			_durations = new Vector.<Number>(numFrames);
			_startTimes = new Vector.<Number>(numFrames);

			for (var i : int = 0; i < numFrames; ++i)
			{
				_durations[i] = _defaultFrameDuration;
				_startTimes[i] = i * _defaultFrameDuration;
			}
		}
		
		public function clear():void
		{
			this.bitmapData = null;
			_textures.splice(0,-1);
		}
		
		public function dispose():void
		{
			for each(var i:Texture in _textures)
			{
				i.dispose();
			}
			clear();
		}

		public function play() : void
		{
			_playing = true;
		}

		public function stop() : void
		{
			_playing = false;
		}

		public function get fps() : int
		{
			return _fps;
		}

		public function set fps(fps : int) : void
		{
			_fps = fps;

			if (fps <= 0)
				throw new ArgumentError(" invalid " + fps);
			// 新的持续时间
			var newFrameDuration : Number = 1.0 / fps;
			// 加速
			var acceleration : Number = newFrameDuration / _defaultFrameDuration;
			// 当前时间变成加速时间
			_currentTime *= acceleration;
			_defaultFrameDuration = newFrameDuration;
			for (var i : int = 0; i < _totalFrame; ++i)
			{
				var duration : Number = _durations[i] * acceleration;
				_totalTime = _totalTime - _durations[i] + duration;
				_durations[i] = duration;
			}
			updateStartTimes();
		}

		private function updateStartTimes() : void
		{
			var numFrames : int = _totalFrame;
			_startTimes.length = 0;
			_startTimes[0] = 0;
			for (var i : int = 1; i < numFrames; ++i)
				_startTimes[i] = _startTimes[i - 1] + _durations[i - 1];
		}

		/**
		 * 跳转到某一帧并且停止
		 * @param frame			位置
		 *
		 */
		public function gotoAndStop(frame : int) : void
		{
			frame = frame < 1 ? 1 : frame;
			frame = frame > _totalFrame ? _totalFrame : frame;
			_currentFrame = frame - 1;
			_playing = false;
			render(_currentFrame);
		}

		/**
		 * 跳转到某一帧并且开始播放
		 * @param frame				位置
		 *
		 */
		public function gotoAndPlay(frame : int) : void
		{
			frame = frame < 1 ? 1 : frame;
			frame = frame > _totalFrame ? _totalFrame : frame;
			_currentFrame = frame - 1;
			_playing = true;
		}

		/**
		 * 渲染
		 * @param texture	texture
		 */
		private function render(frame : int) : void
		{
			var texture : Texture = _textures[_currentFrame];
			if(_isSwfMC)
			{
				this.x = texture.x;
				this.y = texture.y;
//				this.width = texture.width;
//				this.height = texture.height;
			}
			this.bitmapData = texture.bitmapData;
		}

		/**
		 * 获取某一帧的texture
		 * @param frame			帧位置
		 * @return 				texture
		 */
		public function getFrameTexture(frame : int) : Texture
		{
			if (frame < 0 || frame >= _totalFrame)
				return null;

			return _textures[frame];
		}

		/**
		 * 重设某一帧的texture
		 * @param frame			帧位置
		 * @param texture		texture
		 */
		public function setFrameTexture(frame : int, texture : Texture) : void
		{
			if (frame < 0 || frame >= _totalFrame)
				return;

			_textures[frame] = texture;
		}
		
		public function get loop() : Boolean
		{
			return _loop;
		}
		
		public function set loop(loop : Boolean) : void
		{
			_loop = loop;
		}
		
		public function clone():MovieClipSub
		{
			var cloneMc:MovieClipSub = 
				new MovieClipSub(_textures.concat(), this.fps);
			cloneMc.name = this.name;
			cloneMc.isSwfMC = this._isSwfMC;
			cloneMc.loop = this.loop;
			return cloneMc;
		}
		
		/**
		 * 通过passed time来显示对应的帧的图像 
		 * -----------------------------------------------
		 * 1、之前准备通过passedTime来计算正确帧。例如flash被挡住
		 * 之后，会默认降频，那么重新恢复的时候，就应该播放以原来帧
		 * 频速度对应的帧
		 * ------------------------------------------------
		 * 2、考虑，既然flash降频，那么所有的动画也被降频，何必强制
		 * 这个动画的正确帧呢？
		 * @param passedTime					passedtime
		 */		
		public function advanceTime(passedTime : Number) : void
		{
			if (_playing == false)
				return;
			if(_loop == false && _currentFrame == _totalFrame)
            {
                stop();
                return;
            }
				
			// 如果是循环状态,并且当前帧为最后一帧
			if(_loop && _currentFrame == _totalFrame)
				_currentFrame = 0;
			// 播放到最后一帧
//			if(_currentFrame == _totalFrame - 1)
//				if(hasEventListener(Event.COMPLETE))
//					dispatchEvent(new Event(EventBM.COMPLETE, true));
			
			render(_currentFrame);
			_currentFrame++;
			
//			// 最后一针
//			var finalFrame:int;
//			// 之前的帧
//			var previousFrame:int = _currentFrame;
//			var breakAfterFrame:Boolean = false;
//			// 循环状态重置计数
//			if (_loop && _currentTime == _totalTime) 
//			{ 
//				_currentTime = 0.0; 
//				_currentFrame = 0; 
//			}
//			// 播放状态
//			if (_playing && passedTime > 0.0 && _currentTime < _totalTime) 
//			{				
//				_currentTime += passedTime;
//				finalFrame = _textures.length - 1;
//				// 废弃这种方式，因为帧频降低，完全会导致更多的降低帧频
//				// 当前时间大于当前帧+当前帧的duration时间
//				while (_currentTime >= _startTimes[_currentFrame] + _durations[_currentFrame])
//				{
//					// 如果是最后一帧
//					if (_currentFrame == finalFrame)
//					{
//						// 如果有监听完成事件
//						if (hasEventListener(Event.COMPLETE))
//						{
//							if (_currentFrame != previousFrame)
//								render(_currentFrame);
//							// 重置当前时间为总时间
//							_currentTime = _totalTime;
//							// 派发事件
//							dispatchEvent(new Event(EventBM.COMPLETE));
//							breakAfterFrame = true;
//						}
//						// 如果是循环状态
//						if (_loop)
//						{
//							_currentTime -= _totalTime;
//							_currentFrame = 0;
//						}
//						else
//						{
//							_currentTime = _totalTime;
//							breakAfterFrame = true;
//						}
//					}
//					else
//					{
//						_currentFrame++;
//					}
//					
//					if (breakAfterFrame) 
//						break;
//				}
//			}
//			if (_currentFrame != previousFrame)
//				render(_currentFrame);
			
		}

	}
}
