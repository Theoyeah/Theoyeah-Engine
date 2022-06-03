package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import openfl.Lib;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var framerate:Null<Option> = null;

	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing',
			'bool',
			true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		framerate = if(ClientPrefs.newFramerate)
			new Option('Framerate',
				   "Pretty self explanatory, isn't it?",
				   'framerate',
				   'int',
			60) else
				new Option('New Framerate',
					   "Pretty self explanatory, isn't it?",
					   'newFramerate',
					   'int',
				60);
		addOption(framerate);
		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;

		var option:Option = new Option('New Framerate',
			'If checked, the new framerate system will be added',
			'newFramerate',
			'bool',
			true);
		addOption(option);
		#end

		/*
		var option:Option = new Option('Persistent Cached Data',
			'If checked, images loaded will stay in memory\nuntil the game is closed, this increases memory usage,\nbut basically makes reloading times instant.',
			'imagesPersist',
			'bool',
			false);
		option.onChange = onChangePersistentData; //Persistent Cached Data changes FlxGraphic.defaultPersist
		addOption(option);
		*/
		var option:Option = new Option('Shaders', 
			'If checked, you can use shaders to customize your gameplay!', 
			'shaders', 
			'bool', 
			true); 
		addOption(option);

		var option:Option = new Option('Auto Pause', 
		'If enabled, will pause when the app is unfocused.', 
		'autoPause', 
		'bool', 
		true); 
	addOption(option);

		super();
	}

	function reloadFpsOption() {
		framerate = if(ClientPrefs.newFramerate)
			new Option('Framerate',
				   "Pretty self explanatory, isn't it?",
				   'framerate',
				   'int',
			60) else
				new Option('New Framerate',
					   "Pretty self explanatory, isn't it?",
					   'newFramerate',
					   'int',
				60);
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(!ClientPrefs.newFramerate) {
			if(ClientPrefs.framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = ClientPrefs.framerate;
				FlxG.drawFramerate = ClientPrefs.framerate;
			}
			else
			{
				FlxG.drawFramerate = ClientPrefs.framerate;
				FlxG.updateFramerate = ClientPrefs.framerate;
			}
		} else {
			var fps:Int = ClientPrefs.framerate;
			var frame:Int = fps;
			if(ClientPrefs.framerate > 100 && ClientPrefs.framerate < 120)
				fps = frame / 2 - 20;
			else if(ClientPrefs.framerate > 60 && ClientPrefs.framerate < 100)
				fps = frame / 2;
			ClientPrefs.newFramerate = fps;
		}
		reloadFpsOption();
	}
}
