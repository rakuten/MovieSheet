MovieSheet
==========

ActionScript 3.0 Dynamic Convert MovieClip To Bitmap Render Engine

MovieSheetMovieClipBitmap16k(....^^)1100!


MovieSheet:
--------------
+(!)
+
+Bitmap
+
+BitmapData
+
+(hitTestPoint())
+180024(300010)
+MovieClip
+MovieClip(MovieClip)


:
------------
###
```actionscript
		//
		var npc:MovieClip = new NpcAsset();
		addChild(npc);
		
		//MovieSheet48MC
		var npc:MovieClip = new MovieSheet (new NpcAsset());
		addChild(npc);

		//MovieTween
		var sword:MovieClip = new MovieTween(new SwordAsset);
		
		//MovieSheetMovieTween
```

###
```actionscript
		npc.scale = 1.2;
		//scaleBitmapData
```

###
```actionscript
		npc.dispose();
		//ps:dispose()
		//0BitmapData
```

###
```actionscript
		npc.enableTransparentEvent = false;
		//false
```

###Bitmap
```actionscript
		//2flase
		var npc:MovieClip = new MovieSheet (new NpcAsset(), false);
		addChild(npc);
		
		//scale
		npc.scale = 1;
		//
		//npc.scale = 0.5;
		//npc.scale = 1.75;
```

###
```actionscript
		npc.addEventListener(Event.COMPLETE, npc_drawCompleteHandler);
		//scale
```

###
```actionscript
		//mcname
		var npcMc:MoiveClip = new NpcAsset();
		npcMc.name = "npc";
		var npc:MoiveClip = new MovieSheet(npcMc);
		addChild(npc);
		
		//npcMcname
		//BitmpaData
		//npc1npc2
		var npcMc1:MoiveClip = new NpcAsset();
		npcMc1.name = "npc";
		var npc1:MoiveClip = new MovieSheet(npcMc1);
		addChild(npc1);
		
		var npcMc2:MoiveClip = new NpcAsset();
		npcMc2.name = "npc";
		var npc2:MoiveClip = new MovieSheet(npcMc2);
		addChild(npc2);
		//npc2scale
		//scale
		//MovieSheetNpcAsset
```

FAQ:
----------------
**MovieClip?**
`180024`

**?**
`MovieSheet.scale`

**scalescaleXscaleY?**
`scaleXscaleY`

**Worker?**
``
