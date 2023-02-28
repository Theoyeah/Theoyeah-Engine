package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
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

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Note Splashes:',
			"What type of noteSplashes do you want?",
			'noteSplashes',
			'string',
			'Normal',
			['Normal', 'None', /*'Original',*/ 'Inverted', 'Red', 'Pink', 'Cyan', 'Green', 'IDK', 'Saturated']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Intro Background',
			"If checked, there will be a background in intro.",
			'introbg',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Judgement Counter',
			"If checked, there will be a judgement counter when playing.",
			'crazycounter',
			'bool',
			true);
		addOption(option);
		
		var option:Option = new Option('Old Fps font',
			"You're getting nostalgic about the old font for fps? Then this is for you...?",
			'defaultfps',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Icon Bounce:',
			'How should your icons bounce?',
			'iconBounce',
			'string',
			'Default',
			['Default', 'Golden Apple', 'None']);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hide Score Text',
			"If checked, the text under the health bar will not be showed.",
			'noscore',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Kade Engine Score Text',
			"If checked, the text below the health bar\nwill change to Kade Engine.",
			'kadetxt',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Follow Player Pose',
			"If checked, the camera will move when you press a note.",
			'camfollow',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Longer Health Bar',
			"If unchecked, the health bar will be set to the original one.",
			'longhealthbar',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides the FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		
		var option:Option = new Option('RAM Counter',
			'If unchecked, hides the RAM Counter.',
			'showRAM',
			'bool',
			true);
		addOption(option);
		#end

		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'Turn this off to never check for updates when you start the game\nNOT RECOMMENDED.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end 

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			'bool',
			true);
		addOption(option);

		super();
	}
}
