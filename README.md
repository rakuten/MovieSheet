MovieSheet
==========

ActionScript 3.0 Dynamic Convert MovieClip To Bitmap Render Engine

MovieSheet是一款将MovieClip动态转换为Bitmap的引擎，整个库的大小为16k，设计初衷是为优化旧的纯矢量资源项目，以尽量少的修改工作量，来实现项目的性能优化，但实际使用下来发现，不单是旧项目可以进行性能优化，新项目的使用也绝对是游刃有余，只需修改半行代码(你没看错，只需半行....^^)，即可让你的矢量项目转变为位图项目，无需任何编辑器，无需预先导出序列帧，无需修改图形资源，甚至基本无需改原有代码，1秒让你的项目性能瞬间提升100倍!


MovieSheet特点:
--------------
+ 支持缩放处理(再也不会因为缩放而出锯齿了!)
+ 支持矢量资源的镜像，缩放，反转
+ 自带生成位图时的分帧解析以优化生成Bitmap时的卡顿
+ 自带资源释放管理
+ 多实例共用同一BitmapData降低内存占用
+ 支持透明区域点击判断
+ 支持透明区域碰撞判断(hitTestPoint())
+ 同屏1800个对象可维持在24帧速率(3000个对象可维持在10帧)
+ 支持MovieClip的帧标签
+ 完全兼容MovieClip所有接口(本身就是MovieClip子类)


使用方法:
----------
**实例化**
```actionscript
		//旧代码
		var npc:MovieClip = new NpcAsset();
		addChild(npc);
		
		//使用MovieSheet，专用于多帧嵌套动画序列，如4或8方向角色MC
		var npc:MovieClip = new MovieSheet (new NpcAsset());
		addChild(npc);

		//使用MovieTween，专用于纯补间动画
		var sword:MovieClip = new MovieTween(new SwordAsset);
		
		//MovieSheet与MovieTween使用方法全完相同，仅为了处理不同类型资源的逻辑而区分开
```

**缩放**
```actionscript
		npc.scale = 1.2;
		//每次设置scale时都会重绘BitmapData，以达到消除锯齿的目地
```

**回收**
```actionscript
		npc.dispose();
		//ps:请为每个实例单独调用dispose()方法，
		//内部资源管理会在资源引用计数为0的情况下消毁BitmapData
```

**透明区域点击**
```actionscript
		npc.enableTransparentEvent = false;
		//如设置为false则性能会有些微的下降
```

**延迟绘制Bitmap**
```actionscript
		//实例化时将第2个参数设置为flase
		var npc:MovieClip = new MovieSheet (new NpcAsset(), false);
		addChild(npc);
		
		//然后在你想要绘制的地调用scale
		npc.scale = 1;
		//当然，也可以设置为任何你想要的缩放比例
		//npc.scale = 0.5;
		//npc.scale = 1.75;
```

**判断绘制完成**
```actionscript
		npc.addEventListener(Event.COMPLETE, npc_drawCompleteHandler);
		//每次设置scale参数时，也都会触发此事件
```

**内存共享**
```actionscript
		//仅需为原来的mc设置相同的name值，即可达到内存共享的目的
		var npcMc:MoiveClip = new NpcAsset();
		npcMc.name = "npc";
		var npc:MoiveClip = new MovieSheet(npcMc);
		addChild(npc);
		
		//不管传入的npcMc是否为同一个实例，只要name值一样，即可进行内存共享
		//所有BitmpaData仅会在第一次传入后绘制生成，也就是说就算你像下面这样用
		//npc1和npc2也会显示出完全相同的内容
		var npcMc1:MoiveClip = new NpcAsset();
		npcMc1.name = "npc";
		var npc1:MoiveClip = new MovieSheet(npcMc1);
		addChild(npc1);
		
		var npcMc2:MoiveClip = new MovieClip();
		npcMc2.name = "npc";
		var npc2:MoiveClip = new MovieSheet(npcMc2);
		addChild(npc2);
		//但这样使用会造成npc2无法正常使用scale参数(因为使用的是一个空MC)
		//如果想正常使用scale进行缩放，
		//请在MovieSheet实例化时传入真实的NpcAsset实例
```

FAQ:
----------------
**使用MovieClip作为基类性能是否有影响?**

经测试，同屏1800个对象可维持24帧的速率

**缩放后有锯齿怎么办?**

请使用MovieSheet.scale参数进行缩放

**为什么使用scale进行缩放，而不是scaleX和scaleY?**

为兼容旧项目考虑，某些旧项目会使用负数的scaleX和scaleY进行镜像

**为什么不使用Worker进行进一步性能优化?**

考虑到手机程序不支持多线程，所以未实现，但不排队以后实现的可能
