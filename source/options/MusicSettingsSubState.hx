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

class MusicSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Music';
		rpcTitle = 'Music Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		/*var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);*/

		/*
		var option:Option = new Option('Persistent Cached Data',
			'If checked, images loaded will stay in memory\nuntil the game is closed, this increases memory usage,\nbut basically makes reloading times instant.',
			'imagesPersist',
			'bool',
			false);
		option.onChange = onChangePersistentData; //Persistent Cached Data changes FlxGraphic.defaultPersist
		addOption(option);
		*/

		var option:Option = new Option('Music',
			'What music you want to play',
			'musicSelected',
			'String',
			'freakyMenu',
			['freakyMenu', 'offsetSong', 'breakfast', 'tea-time', 'flyAgainBro']);
		addOption(option);
		
		var option:Option = new Option('Hitsound Volume',
			'Funny notes does \"Tick!\" when you hit them."',
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		if(FlxG.keys.pressed.SHIFT) {
			if(ClientPrefs.multiplicativeValue > 0) {
				option.changeValue = ClientPrefs.multiplicativeValue;
			} else {
				option.changeValue = 0.5;
			}
		} else {
			option.changeValue = 0.1;
		}
		option.decimals = 1;
		


		super();
	}
}
