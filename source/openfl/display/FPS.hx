package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;
	public var memoryMegas:Float;
	public var memoryTotal:Float;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 18, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 13, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		memoryMegas = 0;
		memoryTotal = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if(ClientPrefs.newFramerateThing && currentFPS > ClientPrefs.newFramerate)
			currentFPS = ClientPrefs.newFramerate;
		else if(currentFPS > ClientPrefs.framerate)
			currentFPS = ClientPrefs.framerate;

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = "FPS: " + currentFPS;
			
			#if openfl
			memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
			//memoryMegas = Math.round(System.totalMemory / 1024 / 1024 * 100)/100;
			if(memoryMegas > memoryTotal)
				memoryTotal = memoryMegas;
			text += "\nRAM: " + memoryMegas + "mb" + " / " + memoryTotal + 'mb';
			#end

			var fps_:Int = if(ClientPrefs.newFramerateThing) (ClientPrefs.newFramerate + 20) * 2 else ClientPrefs.framerate;
			if(ClientPrefs.newFramerateThing) {
				if(ClientPrefs.newFramerate > 100 && ClientPrefs.newFramerate < 120)
					fps_ = Std.int((ClientPrefs.framerate / 2) - 20);
				else if(ClientPrefs.newFramerate > 60 && ClientPrefs.newFramerate < 100)
					fps_ = Std.int(ClientPrefs.framerate / 2);
				else if(ClientPrefs.newFramerate > 121)
					fps_ = Std.int(ClientPrefs.framerate / 3);
			}

			textColor = 0xFFFFFFFF;
			if (memoryMegas > 3000 || currentFPS <= fps_)
			{
				textColor = 0xFFFF0000;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";
		}

		cacheCount = currentCount;
	}
}
